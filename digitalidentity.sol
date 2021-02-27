pragma solidity >=0.4.22 <0.6.0;
contract digitalIdentity
{
    struct person
    {
        string dateOfBirth;
        string privateKey;
        address[] parents;
    }
    
    address admin;
    mapping(address=>person) citizens;
    mapping(string=>address) hashToAddress;
    mapping(string=>address) recoveryAddress;
    mapping(string=>string) keys;
    mapping (address => bool) validCitizen;

    
    constructor() public
    {
        admin = msg.sender;
    }
    
    modifier onlyAdmin(){
        require(msg.sender==admin);
        _;
    }
    
    function getAdmin() public view 
    returns (address) 
    {
        return admin;
    }
    
    
    
    function setHashToAddress(string memory hashWithkey, string memory hashWithoutkey, address _address)
    onlyAdmin public
    {
        hashToAddress[hashWithkey] = _address;
        recoveryAddress[hashWithoutkey]=_address;
        
    }
    
    function changePrivatekey( string memory hashWithoutkey, string memory newPrivateKey)
    onlyAdmin public
    {
        address _citizenAddress = recoveryAddress[hashWithoutkey];
        string memory oldPrivatekey = keys[hashWithoutkey];
        string memory oldhashWithkey = string(abi.encodePacked(hashWithoutkey, oldPrivatekey));
        delete hashToAddress[oldhashWithkey]; 
        delete validCitizen[hashToAddress[oldhashWithkey]];
        citizens[_citizenAddress].privateKey = newPrivateKey;
        string memory newhashWithkey = string(abi.encodePacked(hashWithoutkey, newPrivateKey));
        setHashToAddress(newhashWithkey,hashWithoutkey,_citizenAddress);
        
        
    }
    
    
    function getHashToAddress(string memory hashWithkey)
    onlyAdmin public view 
    returns (address)
    {
        return hashToAddress[hashWithkey];
    }

    
    function setCitizenInfo
    (
        string memory  hashWithkey, 
        string memory  hashWithoutkey,
        string memory  _dateOfBirth, 
        string memory  _privateKey,
        address _fatherAddress,
        address _motherAddress,
        address _citizenAddress
    )onlyAdmin public 
        
       {

            setHashToAddress(hashWithkey, hashWithoutkey, _citizenAddress);
            keys[hashWithoutkey] = _privateKey;
            
            citizens[_citizenAddress].dateOfBirth = _dateOfBirth;
            citizens[_citizenAddress].privateKey = _privateKey;
            citizens[_citizenAddress].parents.push(_fatherAddress);
            citizens[_citizenAddress].parents.push(_motherAddress);
            validCitizen[_citizenAddress] = true;
             
        }
    
    function getCitizenInfo(string memory  hashWithkey)
    onlyAdmin view public 
    returns (string memory, address, address)
    {
        address _citizenAddress = hashToAddress[hashWithkey];
        person memory p = citizens[_citizenAddress];
        return (p.dateOfBirth, p.parents[0], p.parents[1]);
        
    }
    
    function isCitizen(string memory  hashWithkey) view public 
    returns (bool)
    {
        return validCitizen[hashToAddress[hashWithkey]];
    }
}
