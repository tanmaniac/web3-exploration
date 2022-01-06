// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: monospace; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = ["Everywhere", "Yesterday", "Overconfidently", "Diligently", "Shrilly", "Dimly", "Less", "Knottily", "Vivaciously", "Lively", "Suspiciously", "Shakily", "Likely", "Eventually", "Also", "Lazily", "Needily", "Early", "Bleakly"];
    string[] secondWords = ["Whisper", "Identify", "Measure", "Cure", "Place", "Guard", "Yell", "Pack", "Time", "Share", "Bare", "Remind", "Knot", "Whirl", "Surround", "Phone", "Reduce", "Knock", "Memorize", "Provide"];
    string[] thirdWords = ["Sofa", "Color", "Partner", "Bells", "Face", "Zipper", "Battle", "Cemetary", "Cabbage", "Tin", "Giraffe", "Belief", "Bomb", "Cap", "Songs", "Mom", "Floor", "Finger", "Respect", "Beginner"];

    constructor() ERC721 ("SquareNFT", "SQUARE") {
        console.log("Constructing the NFT contract");
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function pickRandomFirstWord(uint256 tokenId) public view returns(string memory) {
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns(string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns(string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function makeAnEpicNFT() public {
        uint256 newItemId = _tokenIds.current();

        string memory firstWord = pickRandomFirstWord(newItemId);
        string memory secondWord = pickRandomSecondWord(newItemId);
        string memory thirdWord = pickRandomThirdWord(newItemId);
        string memory phrase = string(abi.encodePacked(firstWord, secondWord, thirdWord));

        string memory finalSvg = string(abi.encodePacked(baseSvg, phrase, "</text></svg>"));

        // base64 encode the SVG
        string memory json = Base64.encode(
            bytes(string(abi.encodePacked(
                '{"name": "', phrase,'", "description": "A highly coveted collection of squares.", "image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(finalSvg)),
                '"}'
            )))
        );

        string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));

        console.log("\n--------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("--------------------\n");

        // Mint the NFT to the sender
        _safeMint(msg.sender, newItemId);

        // Set the NFT's data
        _setTokenURI(newItemId, finalTokenUri);

        console.log("An NFT with ID %s has been minted to %s", newItemId, msg.sender);

        // Increment the counter for when the next NFT is minted
        _tokenIds.increment();
    }
}