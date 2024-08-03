pragma solidity ^0.8.0;

contract SimpleCaesarCipher {
    uint8 public shift;
    address public owner;
    
    // Structure to store message details
    struct Message {
        address sender;
        address receiver; // Added receiver address
        string content;
        uint256 timestamp;
    }
    
    // Array to store messages
    Message[] public messageHistory;

    // Event emitted when a new message is sent
    event MessageSent(address indexed sender, address indexed receiver, string content, uint256 timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(uint8 _shift) {
        shift = _shift % 26; // Ensure shift is within 0-25 range
        owner = msg.sender; // Set the contract creator as the owner
    }

    // Encrypt a string
    function encryptString(string memory plaintext) public view returns (string memory) {
        bytes memory plainBytes = bytes(plaintext);
        bytes memory cipherBytes = new bytes(plainBytes.length);

        for (uint i = 0; i < plainBytes.length; i++) {
            cipherBytes[i] = _shiftChar(plainBytes[i], shift);
        }

        return string(cipherBytes);
    }

    // Decrypt a string
    function decryptString(string memory ciphertext) public view returns (string memory) {
        bytes memory cipherBytes = bytes(ciphertext);
        bytes memory plainBytes = new bytes(cipherBytes.length);

        for (uint i = 0; i < cipherBytes.length; i++) {
            plainBytes[i] = _shiftChar(cipherBytes[i], 26 - shift);
        }

        return string(plainBytes);
    }

    // Send an encrypted message (only callable by owner)
    function sendMessage(address receiver, string memory plaintext) public onlyOwner {
        require(receiver != address(0), "Invalid receiver address"); // Ensure the receiver address is valid

        string memory encryptedMessage = encryptString(plaintext);
        Message memory newMessage = Message({
            sender: msg.sender,
            receiver: receiver,
            content: encryptedMessage,
            timestamp: block.timestamp
        });
        
        messageHistory.push(newMessage);
        emit MessageSent(msg.sender, receiver, encryptedMessage, block.timestamp);
    }

    // Retrieve the message history for the caller address
    function getMyMessages() public view returns (Message[] memory) {
        uint count = 0;

        // Count the number of messages for the caller
        for (uint i = 0; i < messageHistory.length; i++) {
            if (messageHistory[i].receiver == msg.sender) {
                count++;
            }
        }

        Message[] memory myMessages = new Message[](count);
        uint index = 0;

        // Collect the messages for the caller
        for (uint i = 0; i < messageHistory.length; i++) {
            if (messageHistory[i].receiver == msg.sender) {
                myMessages[index] = messageHistory[i];
                index++;
            }
        }

        return myMessages;
    }

    // Internal function to shift characters
    function _shiftChar(bytes1 char, uint8 shiftAmount) internal pure returns (bytes1) {
        if (char >= 'a' && char <= 'z') {
            return bytes1((uint8(char) - 97 + shiftAmount) % 26 + 97);
        } else if (char >= 'A' && char <= 'Z') {
            return bytes1((uint8(char) - 65 + shiftAmount) % 26 + 65);
        } else {
            return char; // Non-alphabetical characters remain unchanged
        }
    }
}
