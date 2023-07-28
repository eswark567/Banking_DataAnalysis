use inclass;
select *  from bank_account_details;
select *  from bank_account_transaction;
select *  from bank_account_relationship_details;
select *  from bank_interest_rate;
select *  from bank_customer;
select *  from bank_customer_export;
select *  from bank_customer_messages;
select *  from bank_holidays;
select * from bank_interest_rate;

/* Question.1-1st approach-1. Print credit card transactions with sum of 
transaction_amount on all Fridays and sum of transaction_amount on all other days. */

with tbl as
 (select t2.* from (select account_number 
 from bank_account_details
 where account_type like '%credit card%') as t1,
 bank_account_transaction as t2
 where t1.account_number=t2.account_number)
 select abs(sum(if(dayname(transaction_date)='Friday',transaction_Amount,0))) as friday_trans,
 abs(sum(if(dayname(transaction_date)!='Friday',transaction_Amount,0))) as NOn_friday_trans
 from tbl ;
             -- 2nd approach ------
 
 select abs(sum(if(dayname(transaction_date)='Friday',transaction_Amount,0))) as Friday_trans,
 abs(sum(if(dayname(transaction_date)!='Friday',transaction_Amount,0))) as NON_friday
 from bank_Account_transaction 
 where account_number in
 (select account_number from bank_account_details 
 where account_type 
 like '%credit card%');
 
/* Question:2 ::Show the details of credit cards along with the
 aggregate transaction amount during holidays and non holidays.
*/
 
 with CC as
 (select t2.* from 
 (select account_number 
 from bank_account_details 
 where account_type like '%credit card%')t1,
 bank_account_transaction as t2
 where t1.account_number=t2.account_number)
 select cc.account_number,sum(if(cc.transaction_date in(select holiday from bank_holidays),abs(cc.transaction_amount),null)) as "holidays",
 sum(if(cc.transaction_date not in( select holiday from bank_holidays),abs(cc.transaction_amount),null)) as 'Non-Holidays'
 from cc group by cc.account_number;
 
 /*Generate a report to Send Ad-hoc holiday greetings - “Happy Holiday” for
 all transactions occurred during Holidays in 3rd month.
 */
 
 with
 hhhg as
 (select *
 from bank_account_transaction 
 where transaction_date 
 in(select holiday from bank_holidays where month(holiday)=3))
 
 select hhhg.*,'Happy holiday' Message from hhhg;
 
 /*QUESTION 4::Calculate the Bank accrued interest with respect to their RECURRING DEPOSITS
for any deposits older than 30 days .
Note: Accrued interest calculation = transaction_amount * interest_rate
Note: use CURRENT_DATE()
 */
select account_type,account_number,sum(transaction_amount)*(interest_rate)
from 
(select bad.account_type,bat.transaction_amount,bat.account_number,bat.transaction_date,barr.interest_rate
from bank_account_transaction bat
join bank_account_details bad
on bat.account_number=bad.account_number
join bank_interest_rate barr
on barr.account_type=bad.account_type
 where bat.account_number in
 (select account_number from bank_account_details where account_type='Recurring deposits')) bas
 
where transaction_date< date_sub(curdate(),interval 30 day)
group by account_number; 

-- q4 2nd approach ----

with abb as
(select bat.* from (select * from bank_account_details where account_type='Recurring deposits')bad,
	bank_account_transaction bat
    where bad.account_number=bat.account_number)
    
    select abb.account_number,bir.account_type,sum(abb.transaction_amount)*(bir.interest_rate)
    from abb,
    bank_interest_rate bir
    
    where bir.account_type='Recurring deposits' and abb.transaction_date< date_sub(curdate(),interval 30 day)
    group by abb.account_number;
   
/* QUESTION 5:: Display the Savings Account number whose corresponding Credit cards and
AddonCredit card transactions have occured more than one time
*/
    select *  from bank_account_relationship_details;
    select * from bank_account_transaction;
 
 select bass.savings_account,bass.bank_acc,bat.account_number,bass.cctype,count(bat.account_number) from (select bard.linking_account_number savings_account,
 bad.account_type bank_acc,
 bard.account_number cc,
 bard.account_type ccType
 from bank_account_relationship_details bard
 join bank_account_details bad
 on bard.linking_account_number=bad.account_number
 where bard.account_type='credit card')bass
 join bank_account_transaction bat
 on bat.account_number=bass.cc
 group by bat.account_number
 having count(bat.account_number)>1;
 
 with abc as
 (select bat.*,bard.linking_account_number,bard.account_type from
 (select * from bank_account_relationship_details 
 where account_type like ('%Credit%'))bard,
 bank_account_transaction bat
 where bat.account_number=bard.account_number)
 
 select bad.account_number,bad.account_type,abc.account_number,abc.account_type,count(abc.account_number) 
 from abc,
 bank_account_details bad
 where bad.account_number=abc.linking_account_number
 group by bad.account_number,bad.account_type,abc.account_number,abc.account_type
 having count(abc.account_number)>1;
 
/* UESTION 6 ::Display the Savings Account number whose corresponding AddonCredit card
transactions have occured atleast once.
PRE-requisite ( The below record is needed for the next two questions.
If you had already added above , ignore this )
-- INSERT INTO BANK_CUSTOMER_EXPORT VALUES ('123008',"Robin", "3005-1,Heathrow",
"NY" , "1897614000");
*/
 select * from bank_Account_relationship_details
 where account_type='Credit card';
 
 with abc as
 (select bat.*,bard.linking_account_number,bard.account_type from
 (select * from bank_account_relationship_details 
 where account_type like 'ADD-on credit card')bard,
 bank_account_transaction bat
 where bat.account_number=bard.account_number)
 
 select bad.account_number,bad.account_type,abc.account_number,abc.account_type,count(abc.account_number) 
 from abc,
 bank_account_details bad
 where bad.account_number=abc.linking_account_number
 group by bad.account_number,bad.account_type,abc.account_number,abc.account_type
 having count(abc.account_number)=1;
 
/*QUESTION 7 :: Print the customer_id and length of customer_id using Natural join on
Tables :bank_customer and bank_customer_export
Note: Do not use table alias to refer to column names.
*/
 select * from bank_customer;
 select * from bank_customer_export;
 
 select customer_id,length(customer_id) 
 from bank_customer
 natural join bank_customer_export;
 
 /*
 QUESTION 8 ::Print customer_id, customer_name and other common columns from both the
Tables : bank_customer & bank_customer_export without missing any matching
customer_id key column records.
Note: refer datatype conversion if found any missing record
 */
 select * from bank_customer_export;

select t1.customer_id,t1.customer_name,
       t1.address,t1.state_code,t1.telephone	
from bank_customer t1
natural join bank_customer_export ;
-- t1.customer_id=bank_customer_export.customer_id;