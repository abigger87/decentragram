pragma solidity ^0.5.0;

contract Owner {
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract Decentragram is Owner {
    string public name = "Decentragram";
    uint256 public imageCount = 0;
    struct Image {
        uint256 id;
        string hash;
        string description;
        uint256 tipAmount;
        address payable author;
    }

    event ImageCreated(
        uint256 id,
        string hash,
        string description,
        uint256 tipAmount,
        address payable author
    );

    event ImageTipped(
        uint256 id,
        string hash,
        string description,
        uint256 tipAmount,
        address payable author
    );

    event ImageDeleted(
        uint256 id,
        string hash,
        string description,
        uint256 tipAmount,
        address payable author
    );

    // * Store Images: ipfs hash -> image
    mapping(uint256 => Image) public images;
    mapping(string => uint256) private getIdFromHash;

    // * Create Images
    function uploadImage(string calldata _hash, string calldata _description)
        external
    {
        // * Null Checks
        require(
            bytes(_hash).length > 0,
            "Must have a hash of length non-zero."
        );
        require(
            bytes(_description).length > 0,
            "Must have a description of length non-zero."
        );
        require(msg.sender != address(0), "Sender must not be empty address.");

        // * Increment Image Id
        ++imageCount;

        // * Add Image to Contract
        images[imageCount] = Image(
            imageCount,
            _hash,
            _description,
            0,
            msg.sender
        );

        // * Record Hash to Id Mapping For Fetching Image Internally
        getIdFromHash[_hash] = imageCount;

        // * Trigger Event
        emit ImageCreated(imageCount, _hash, _description, 0, msg.sender);
    }

    // * Tip Images
    function tipImageOwner(uint256 _imageId) external payable {
        require(
            _imageId > 0 && _imageId <= imageCount,
            "Must tip valid image."
        );
        require(
            msg.sender != images[_imageId].author,
            "Sender must not be the image author."
        );
        require(msg.sender != address(0), "Sender must not be empty address.");
        require(msg.value > 0, "Tip amount must be greater than 0.");

        Image memory _image = images[_imageId];
        address payable _author = _image.author;
        _author.transfer(msg.value);
        _image.tipAmount = _image.tipAmount + msg.value;
        images[_imageId] = _image;

        emit ImageTipped(
            _imageId,
            _image.hash,
            _image.description,
            _image.tipAmount,
            _author
        );
    }

    // * Delete image
    function deleteImage(string calldata _hash) external {
        require(
            bytes(_hash).length > 0,
            "Must have a hash of length non-zero."
        );
        require(
            msg.sender == images[getIdFromHash[_hash]].author,
            "Author must be the message caller"
        );

        Image memory _image = images[getIdFromHash[_hash]];
        delete images[getIdFromHash[_hash]];

        emit ImageDeleted(
            _image.id,
            _image.hash,
            _image.description,
            _image.tipAmount,
            _image.author
        );
    }
}
