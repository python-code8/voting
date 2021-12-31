//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

contract Voting {
  mapping(address => bool) public voters;

  struct Choice {
    uint id;
    string name;
    uint votes;
  }

  struct Proposal {
    uint id;
    string name;
    Choice[] choices;
    uint end;
  }

  mapping(uint => Proposal) proposal;
  uint nextProposalId;
  address public admin;
  mapping(address => mapping(uint => bool)) votes;
  mapping(address => bool) public isWhitelist;

  constructor() public {
    admin = msg.sender;
  }
  
  function addVoters(address[] calldata _voters) external isAdminOrWhitelist() {
    for(uint i = 0; i < _voters.length; i++) {
        voters[_voters[i]] = true;
    }
  }

  function whitelist(address _user) external {
      require(msg.sender == admin);
      isWhitelist[_user] = true;
  }

  function createProposal(
    string memory name,
    string[] memory _choices,
    uint duration
    ) public isAdminOrWhitelist() {

      proposal[nextProposalId].id = nextProposalId;
      proposal[nextProposalId].name = name;
      proposal[nextProposalId].end = block.timestamp + duration;

      for(uint i = 0; i < _choices.length ; i++) {
        proposal[nextProposalId].choices.push(Choice(i, _choices[i], 0));
      }
      nextProposalId++;
  }

  function vote(uint proposalId, uint choiceId) external {
    require(voters[msg.sender] == true, "only voters can vote");
    require(votes[msg.sender][proposalId] == false, "can only vote once");
    require(block.timestamp < proposal[proposalId].end, "voting time ended");
    votes[msg.sender][proposalId] = true;
    proposal[proposalId].choices[choiceId].votes++;
  }

  
  function results(uint proposalId) 
    view 
    external 
    returns(Choice[] memory) {
    require(block.timestamp >= proposal[proposalId].end, "voting time isn't over yet");
    return proposal[proposalId].choices;
  }


  modifier isAdminOrWhitelist() {
    require(msg.sender == admin || isWhitelist[msg.sender], "Only the admin or a whitelisted members can execute this function");
    _;
  }
}

