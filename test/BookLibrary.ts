import { expect } from "chai";
import { ethers } from "hardhat";
import { BookLibrary } from "../typechain-types"

describe("BookLibrary", function () {
    let bookLibraryFactory;
    let bookLibrary: BookLibrary;

    before(async () => {
        bookLibraryFactory = await ethers.getContractFactory("BookLibrary");

        bookLibrary = await bookLibraryFactory.deploy();

        await bookLibrary.deployed();
    });

    it('Should emit event on added book', async function () {
        expect(await bookLibrary.addBook('bookOne', 5)).to.emit(bookLibrary, "LogAddedBook");
    });

    it('Should throw when adding the same book', async function () {
        await expect(bookLibrary.addBook('bookOne', 5)).to.be.revertedWith('This book is already added')
    });

    it('Should throw when trying to add invalid book', async function () {
        await expect(bookLibrary.addBook('', 0)).to.be.revertedWith('Book data is not valid.')
    });

    it('Should throw when trying to add book with not the owner', async function () {
        const [owner, addr1] = await ethers.getSigners();

        await expect(bookLibrary.connect(addr1).addBook('randomBook', 2)).to.be.revertedWith(
            "Ownable: caller is not the owner"
        );
    });

    it('Should emit event on borrowed book and throw when try to borrow it again', async function () {
        const [owner, addr1] = await ethers.getSigners();

        const bookIdEncrypted = ethers.utils.solidityKeccak256(['string'], ['bookOne'])

        await expect(bookLibrary.connect(addr1).borrowBook(bookIdEncrypted)).to.emit(bookLibrary, "LogBookBorrowed");
        await expect(bookLibrary.connect(addr1).borrowBook(bookIdEncrypted)).to.be.revertedWith('This book is already borrowed by you');
    });

    it('Should throw when try to borrow non existing book', async function () {
        const [owner, addr1] = await ethers.getSigners();

        const bookIdEncrypted = ethers.utils.solidityKeccak256(['string'], ['randomBookName'])

        await expect(bookLibrary.connect(addr1).borrowBook(bookIdEncrypted)).to.be.revertedWith('There is no copies from this book left');
    });

    it('Should return book borrowers by bookId', async function () {
        const [owner, addr1] = await ethers.getSigners();

        const bookIdEncrypted = ethers.utils.solidityKeccak256(['string'], ['bookOne'])

        const res = await bookLibrary.getAllAddressesBorrowedBook(bookIdEncrypted)

        expect(res[0]).to.equal(addr1.address.toString());
    });

    it('Should emit event on returned book and throw when try to return non borrowed book', async function () {
        const [owner, addr1] = await ethers.getSigners();

        const bookIdEncrypted = ethers.utils.solidityKeccak256(['string'], ['bookOne'])

        await expect(bookLibrary.connect(addr1).returnBook(bookIdEncrypted)).to.emit(bookLibrary, "LogBookReturned")
        await expect(bookLibrary.connect(addr1).returnBook(bookIdEncrypted)).to.be.revertedWith("You can't return a book that you haven't borrowed");
    });
});
