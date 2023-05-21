// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BookLibrary is Ownable {
    struct Book {
        uint8 copies;
        string title;
        address[] bookBorrowedAddresses;
    }

    bytes32[] public bookKey;

    mapping(bytes32 => Book) public books;
    mapping (address => mapping(bytes32 => bool)) public borrowedBook;

    event LogAddedBook(string title, uint copies);
    event LogBookBorrowed(string title, address user);
    event LogBookReturned(string title, address user);

    modifier validBookData(string memory _title, uint8 _copies) {
        bytes memory tempTitle = bytes(_title);
        require(tempTitle.length > 0 && _copies > 0, "Book data is not valid.");
        _;
    }

    modifier bookDoesNotExist(string memory _title) {
        require(bytes(books[keccak256(abi.encodePacked(_title))].title).length == 0, "This book is already added");
        _;
    }

    function addBook(string memory _title, uint8 _copies) public onlyOwner validBookData(_title, _copies) bookDoesNotExist(_title) {
        address[] memory borrowed;
        Book memory newBook = Book(_copies, _title, borrowed);
        books[keccak256(abi.encodePacked(_title))] = newBook;
        bookKey.push(keccak256(abi.encodePacked(_title)));
        emit LogAddedBook(_title, _copies);
    }

    function borrowBook(bytes32 bookId) public {
        Book storage book = books[bookId];

        require(book.copies > 0, "There is no copies from this book left");

        require(!borrowedBook[msg.sender][bookId], "This book is already borrowed by you");

        borrowedBook[msg.sender][bookId] = true;
        book.bookBorrowedAddresses.push(msg.sender);
        book.copies--;
        emit LogBookBorrowed(book.title, msg.sender);
    }

    function returnBook(bytes32 bookId) public {
        Book storage book = books[bookId];

        require(borrowedBook[msg.sender][bookId], "You can't return a book that you haven't borrowed");

        borrowedBook[msg.sender][bookId] = false;
        book.copies++;

        emit LogBookReturned(book.title, msg.sender);
    }

    function getAllAddressesBorrowedBook(bytes32 bookId) public view returns(address[] memory _book) {
        Book memory book = books[bookId];
        return book.bookBorrowedAddresses;
    }
}
