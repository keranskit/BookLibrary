import {ethers} from "hardhat";

export async function main(_privateKey: any) {
    const wallet = new ethers.Wallet(_privateKey, ethers.provider);
    console.log("Deploying contracts with the account:", wallet.address);

    const Book_Library_Factory = await ethers.getContractFactory("BookLibrary");
    const bookLibrary = await Book_Library_Factory.connect(wallet).deploy();
    await bookLibrary.deployed();
    console.log(`The BookLibrary contract is deployed to ${bookLibrary.address}`);

    const owner = await bookLibrary.owner();
    console.log(`The BookLibrary contract owner is ${owner}`);
}
