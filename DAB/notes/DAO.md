自治:
是什么:
将权力分配给所有存款点的持有者.

为什么:
民主投票进行程序的运行
自治需要实现的目标:
    需要能够更新程序: 主要是formula,
    需要70%以上的支持率才能够修改DABFormula
    需要50%以上的支持率才能够修改LoanPlanFormula

实现方案:
升级合约的接口,和能够注册,投票,验证和执行升级合约的DAO.

甚至应该能够升级DAO自身.

一个实现了这个接口的升级合约,在获得了超过阈值的支持率后,能够将被DAO运行,然后升级原合约.

投票的过程中,会将投票的DPT转变为一个临时的代币,而这个代币是由Proposal控制的,投了票之后,将选票转给Proposal控制,当proposal结束之后,会开放退还DPT函数.
如果要执行DAO合约中的函数,那么这个proposal需要具有一定比例的代币.这样的机制可以避免一票多投的现象.


DAO是dao, dao(address _proposal, uint8(60))代表的是一个修饰符,这个代表升级合约_proposal需要有60%的支持率才能够运行.

首先第一步是编写一个proposal, 开始时间,结束时间,名称,声明,需要运行的DAO函数,提出新的替换合约.
然后将proposal注册到合约,这个注册需要花费一定金额的存款点
注册合约之后,就可以通过DAO的合约对proposal投票,每个存款点都有一票,注册proposal实际上还将proposal的所有者设置为DAO
如果这个proposal的票数达到能够执行某个更新的阈值之后,那么将通过验证,能够执行DAO上的函数,否则一段时间之后,Proposal不能被投票,进入运行阶段,如果提议失败,则进入退票阶段.
这个合约能够被运行一次.

IProposal{}


DAO
// member
registered proposal list

modifier validProposal(address _proposal){
    // check if _proposal is in registered proposal list
}

modifier dao(address _proposal, uint8 _supportRate){
    // get total vote
    // get vote for proposal
    // compare with _supportRate
}

function register(address _proposal){
    // destroy 100 DPT in _proposal, error if not sufficient DPT in _proposal contract.
    // add to registered proposal list
    // a proposal only used for
}

function transferOwnership(IProposal _proposal)
valid(proposal)
dao(address _proposal, uint8(80))
{
    string proposedFunction = _proposal.proposedFunction();
    require(proposedFunction == 'transferOwnership');
    address proposedOwner = _proposal.proposedOwner();
    DAB.transferOwnership(proposedOwner);
}

function setDABFormula(IProposal _proposal)
valid(proposal)
dao(address _proposal, uint8(80))
{
    string proposedFunction = _proposal.proposedFunction();
    require(proposedFunction == 'setDABFormula');
    address proposedDABFormula = _proposal.proposedDABFormula();
    DAB.setDABFormula(proposedDABFormula);

}


function addLoanPlanFormula(IProposal _proposal)
valid(proposal)
dao(address _proposal, uint8(80))
{
    string proposedFunction = _proposal.proposedFunction();
    require(proposedFunction == 'addLoanPlanFormula');
    address proposedLoanPlanFormula = _proposal.proposedLoanPlanFormula();
    DAB.addLoanPlanFormula(proposedLoanPlanFormula);

}

function vote(IProposal _proposal){
    // DPT balance of msg sender
    // can not vote twice
    // add to vote\[_proposal][]

}

function acceptOwnership()
dao(address _proposal, uint8(50))
{
    DAB.acceptOwnership();
}




