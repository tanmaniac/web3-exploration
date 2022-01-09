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

    string[] floats = ["0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0"];
    string[] colors = ["#025373", "#0396A6", "#EED5B7", "#F29544", "#9BC0D0"];
    string[] colors2 = ["#D95B7D", "#0F1B40", "#048C8C", "#F29D35", "#D93814"];

    uint256 maxTokens = 50;

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    struct SvgInfo {
        string cx;
        string cy;
        string r;
        string fx;
        string fy;
        string startColor;
        string stopColor;
    }

    constructor() ERC721 ("SquareNFT", "SQUARE") {
        console.log("Constructing the NFT contract");
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function pickRandomWord(string memory seed, uint256 tokenId, string[] memory dictionary) internal pure returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(seed, Strings.toString(tokenId))));
        rand = rand % dictionary.length;
        return dictionary[rand];
    }

    function generateSvg(SvgInfo memory svgInfo,
                         string memory phrase) internal pure returns (string memory) {
        string memory svg = string(abi.encodePacked(
            '<svg width="350" height="350" xmlns="http://www.w3.org/2000/svg"><defs><radialGradient id="a" cx="', svgInfo.cx,
            '" cy="', svgInfo.cy,
            '" r="', svgInfo.r,
            '" fx="', svgInfo.fx,
            '" fy="', svgInfo.fy,
            '"><stop offset="0%" stop-color="', svgInfo.startColor,
            '"/><stop offset="100%" stop-color="', svgInfo.stopColor,
            '"/></radialGradient></defs><rect width="100%" height="100%" fill="url(#a)"/><text x="50%" y="50%" fill="#fff" font-family="serif" dominant-baseline="middle" text-anchor="middle" font-size="18">',
            phrase,
            '</text></svg>'
        ));
        return svg;
    }

    function getMaxTokenCount() public view returns (uint256) {
        return maxTokens;
    }

    function getNumTokensMintedSoFar() public view returns (uint256) {
        return _tokenIds.current();
    }

    function makeAnEpicNFT() public {
        uint256 newItemId = _tokenIds.current();

        require(newItemId < maxTokens, "All tokens have been minted!");

        string memory firstWord = pickRandomWord("FIRST_WORD", newItemId, firstWords);
        string memory secondWord = pickRandomWord("SECOND_WORD", newItemId, secondWords);
        string memory thirdWord = pickRandomWord("THIRD_WORD", newItemId, thirdWords);
        string memory phrase = string(abi.encodePacked(firstWord, secondWord, thirdWord));

        // Get gradient settings
        SvgInfo memory svgInfo;

        svgInfo.cx = pickRandomWord("cx", newItemId, floats);
        svgInfo.cy = pickRandomWord("cy", newItemId, floats);
        svgInfo.r = "1.0";
        svgInfo.fx = pickRandomWord("fx", newItemId, floats);
        svgInfo.fy = pickRandomWord("fy", newItemId, floats);
        svgInfo.startColor = pickRandomWord("start_color", newItemId, colors);
        svgInfo.stopColor = pickRandomWord("stop_color", newItemId, colors2);

        string memory finalSvg = generateSvg(svgInfo, phrase);

        console.log(finalSvg);

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

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}