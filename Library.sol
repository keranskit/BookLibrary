// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Ownable.sol";

contract Library is Ownable {

    uint booksCount = 0;
    uint holderOfMapSize = 0;

    struct Book {
        uint id;
        string name;
    }

    event BookBorrowed(address customer, uint bookId, string bookName);

    mapping(uint => string) public bookIdToBookName;
    mapping(string => uint) public bookNameToAvailableBookCopies;
    mapping(uint => address) public holderOf;
    mapping(address => string[]) public borrowedBooks;

    function addBookEdition(string calldata name, uint numberOfCopies) public onlyOwner {
        for (uint i = 0; i < numberOfCopies; i++) {
            bookIdToBookName[booksCount] = name;
            holderOf[booksCount] = address(this);
            holderOfMapSize++;
            booksCount++;
        }

        bookNameToAvailableBookCopies[name] = bookNameToAvailableBookCopies[name] + numberOfCopies;
    }

    function borrowBook(uint bookId) public bookNotBorrowed(bookId) bookIsAvailableForBorrowing(bookId) userDoesNotHaveSimilarBook(bookId) {
        string memory bookName = bookIdToBookName[bookId];
        borrowedBooks[msg.sender].push(bookName);
        bookNameToAvailableBookCopies[bookName]--;

        emit BookBorrowed(msg.sender, bookId, bookName);
    }

    function returnBook(uint bookId) public bookBorrowedBySender(bookId) {
        string memory bookName = bookIdToBookName[bookId];
        string[] memory customerBooks = borrowedBooks[msg.sender];
        string[] memory newBooksArr;
        uint counter = 0;
        for (uint i = 0; i < customerBooks.length; i++) {
            if (keccak256(abi.encodePacked(bookName)) != keccak256(abi.encodePacked(customerBooks[i]))) {
                newBooksArr[counter] = customerBooks[i];
                counter++;
            }
        }

        borrowedBooks[msg.sender] = newBooksArr;
        bookNameToAvailableBookCopies[bookName]++;
    }

    function viewAvailableBooks() public view returns (Book[] memory) {
        Book[] memory result;

        uint counter = 0;
        for (uint i = 0; i < holderOfMapSize; i++) {
            if (holderOf[i] == address(this)) {
                result[counter] = Book(i, bookIdToBookName[i]);
                counter++;
            }
        }

        return result;
    }

    modifier bookNotBorrowed(uint _bookId) {
        require(holderOf[_bookId] == address(this), "Book is already borrowed by someone else!");
        _;
    }

    modifier bookBorrowedBySender(uint _bookId) {
        require(holderOf[_bookId] == msg.sender, "Book is not borrowed by you!");
        _;
    }

    modifier userDoesNotHaveSimilarBook(uint _desiredBookId) {
        bytes32 bookNameEncoded = keccak256(abi.encodePacked(bookIdToBookName[_desiredBookId]));

        for (uint i = 0; i < borrowedBooks[msg.sender].length; i++) {
            require(keccak256(abi.encodePacked(borrowedBooks[msg.sender][i])) != bookNameEncoded , "User already has the book!");
        }

        _;
    }

    modifier bookIsAvailableForBorrowing(uint _bookId) {
        require(bookNameToAvailableBookCopies[bookIdToBookName[_bookId]] > 0, "No available copies!");
        _;
    }
}
