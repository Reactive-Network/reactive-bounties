// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Insurance 
is AccessControl
{

    struct InsurancePlans{
        uint TOTAL_AMOUNT;
        uint INSTALMENT_PAY_AMOUNT;
        uint NOOFINSTALMENT;
        uint TIMEPERIODINMONTHS;
    }
    
    struct userPlanDetails{
        address user;
        string PLAN_NAME;
        uint ENROLED_TIME;
        uint AMOUNT_TO_BE_PAID;
        uint LEFT_INSTALMENTS;
    }
    event Payoutcall(address indexed user ,uint indexed amountleft,string indexed _planName);
    mapping (string =>InsurancePlans ) public planNameToPlan;
    mapping (string => address[]) public planNametoUsersRegistered;
    mapping (address => userPlanDetails) public userPlans;

    bytes32 public constant INSURANCE_MANAGER_ROLE=keccak256("INSURANCE_MANAGER_ROLE");

    constructor(address InsuranceManager){
        _grantRole(INSURANCE_MANAGER_ROLE ,InsuranceManager);
    }

    function addPlans(
        string memory nameofplan,
        uint totalamount,
        uint instalment_pay_amount,
        uint noofinstalment,
        uint noofmonths
        ) public onlyRole(INSURANCE_MANAGER_ROLE) {
            planNameToPlan[nameofplan]=InsurancePlans(
                totalamount,
                instalment_pay_amount,
                noofinstalment,
                noofmonths
            );
        }
    
    function registerForInsurance(string memory nameofinsurance) public {
        require(planNameToPlan[nameofinsurance].TOTAL_AMOUNT!=0,"Plan doesnot exist");
        require(userPlans[msg.sender].LEFT_INSTALMENTS==0);

        userPlans[msg.sender]=userPlanDetails(
            msg.sender,
            nameofinsurance,
            block.timestamp,
            0,
            planNameToPlan[nameofinsurance].NOOFINSTALMENT
        );

        planNametoUsersRegistered[nameofinsurance].push(msg.sender);
    }

    function triggerNewInstallment(string memory _planName)public onlyRole(INSURANCE_MANAGER_ROLE) {
        InsurancePlans memory plan = planNameToPlan[_planName];

        for(uint i=0;i<planNametoUsersRegistered[_planName].length;i++){
            userPlanDetails memory user=userPlans[planNametoUsersRegistered[_planName][i]];
            if(user.LEFT_INSTALMENTS>0){
                user.AMOUNT_TO_BE_PAID+=plan.INSTALMENT_PAY_AMOUNT;
                user.LEFT_INSTALMENTS -=1;
                userPlans[user.user]=user;
                emit Payoutcall(user.user, user.AMOUNT_TO_BE_PAID, _planName);
            }
        }
    } 

    function payInsurance(address to ,uint amount) public payable {
        require(msg.value<=userPlans[to].AMOUNT_TO_BE_PAID);
        require (amount==msg.value);
        userPlanDetails storage user = userPlans[to];
        user.AMOUNT_TO_BE_PAID-=amount;
    }

    function getNoDueReceipt(address user)public view returns(bool){
        return userPlans[user].AMOUNT_TO_BE_PAID==0&&userPlans[user].LEFT_INSTALMENTS==0;
    }
}