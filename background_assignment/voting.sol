// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

contract Ballot {
    struct Voter {
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }

    struct Proposal {
        string name;
        uint voteCount;
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    // Store the time when voting starts and the duration of the vote.
    uint private startTime;
    uint private voteDuration;

    constructor(string[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    function giveRightToVote(address voter) external {
        require(
            msg.sender == chairperson,
            "Only the chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);

        voters[voter].weight = 1;
    }

    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self delegation is disallowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop in delegation.");
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage _delegate = voters[to];
        if (_delegate.voted) {
            proposals[_delegate.vote].voteCount += sender.weight;
        } else {
            _delegate.weight += 1;
        }
    }

    // Modifier that checks whether vote has started and not ended.
    modifier voteEnded() {
        require(startTime != 0, "Voting has not yet started.");
        require(block.timestamp - startTime < voteDuration, "Voting has already finished.");
        _;
    }

    function vote(uint proposal) external voteEnded {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote.");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() public view returns (uint _winningProposal) {
        uint winningVoteCount = 0;

        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                _winningProposal = p;
            }
        }
    }

    function winnerName() external view returns (string memory _winnerName) {
        _winnerName = proposals[winningProposal()].name;
    }

    // Starts the vote.
    function startVote(uint _voteDuration) public {
        require(msg.sender == chairperson, "Not allowed to start the vote.");
        require(startTime == 0, "Voting has already started.");

        startTime = block.timestamp;
        voteDuration = _voteDuration;
    }
}
