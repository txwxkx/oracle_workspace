/*
서브쿼리
1. 스칼라 쿼리 : SELECT
2. 인라인 뷰 : FROM
3. 서브쿼리 : WHERE
*/

--90번 부서에 근무하는 Lex 사원의 근무하는 부서명을 출력하시오.
SELECT department_name
FROM departments
WHERE department_id = 90;

--'Lex'가 근무하는 부서를 찾고 부서명을 출력하시오.
SELECT department_id
FROM employees
WHERE first_name = 'Lex';

SELECT department_name
FROM departments
WHERE department_id = 90;

SELECT d.department_id
FROM employees e, departments d
WHERE e.department_id = d.department_id
AND e.first_name = 'Lex';

SELECT department_name
FROM departments
WHERE department_id = (
                       SELECT department_id
                       FROM employees
                       WHERE first_name = 'Lex'
                       );
                       
                       
--'Lex'와 동일한 업무(job_id)를 가진 사원의 이름(first_name),
--업무명(job_title), 입사일(hire_date)을 출력하시오.
SELECT e.first_name, j.job_title, e.hire_date
FROM employees e, jobs j
WHERE e.job_id = j.job_id
AND e.job_id = (
                SELECT job_id
                FROM employees
                WHERE first_name = 'Lex'
                );
                
--'IT'에 근무하는 사원이름(first_name), 부서번호를 출력하시오.
SELECT first_name, department_id
FROM employees
WHERE department_id = (
                       SELECT department_id
                       FROM departments
                       WHERE department_name = 'IT'
                       );
                       
                       
--'Bruce'보다 급여를 많이 받은 사원이름(first_name), 부서명, 급여를 출력하시오.
SELECT e.first_name, d.department_name, e.salary
FROM employees e, departments d
WHERE e.department_id = d.department_id  
AND e.salary > (
                SELECT salary
                FROM employees
                WHERE first_name = 'Bruce'
                )
ORDER BY e.salary; 


--부서별로 가장 급여를 많이 받는 사원이름, 부서번호, 급여를 출력하시오.(in)
SELECT e.first_name, e.department_id, e.salary
FROM employees e
WHERE (e.department_id, e.salary) IN (
                                      SELECT department_id, max(salary)
                                      FROM employees
                                      GROUP BY department_id
                                      )
ORDER BY department_id;

--30부서의 모든 사원들의 급여보다 더 많은 급여를 받는
--사원이름, 급여, 입사실을 출력하시오. (ALL)
--(서브쿼리에서 max()함수를 사용하지 않는다.);
SELECT first_name, salary, hire_date
FROM employees
WHERE salary > ALL (
                    SELECT salary
                    FROM employees
                    WHERE department_id = 30
                    );
                    
--30부서의 사원들이 받는 최저급여보다 높은 급여를 받는
--사원이름, 급여, 입사일을 출력하시오. (ANY)
--(서브쿼리에서 min()함수를 사용하지 않는다);
SELECT first_name, salary, hire_date
FROM employees
WHERE salary > ANY (
                    SELECT salary
                    FROM employees
                    WHERE department_id = 30
                    );

--사원이 있는 부서만 출력하시오.
SELECT count(*)
FROM departments; /* 총 부서 : 27개 */

SELECT department_id, department_name
FROM departments
WHERE department_id IN (
                        SELECT distinct department_id
                        FROM employees
                        WHERE department_id IS NOT NULL
                        );
                        
SELECT department_id, department_name
FROM departments d
WHERE EXISTS (
              SELECT 1
              FROM employees e
              WHERE e.department_id = d.department_id
              );
              
SELECT department_id, first_name
FROM employees;

--사람이 없는 부서만 출력하시오.
SELECT department_id, department_name
FROM departments d
WHERE NOT EXISTS (
                  SELECT 1
                  FROM employees e
                  WHERE e.department_id = d.department_id
                  );
                  
--관리자가 있는 사원의 정보를 출력하시오.
SELECT w.employee_id, w.first_name, w.manager_id
FROM employees w
WHERE EXISTS (
              SELECT 1
              FROM employees m
              WHERE w.manager_id = m.manager_id
              );

--관리자가 없는 사원의 정보를 출력하시오.
SELECT w.employee_id, w.first_name, w.manager_id
FROM employees w
WHERE NOT EXISTS (
                  SELECT 1
                  FROM employees m
                  WHERE w.manager_id = m.manager_id
                  );                  


/*-----------------------------------------------------------
       문제
 -------------------------------------------------------------*/
1) department_id가 60인 부서의 도시명을 알아내는 SELECT문장을 기술하시오

    
2)사번이 107인 사원과 부서가같고,167번의 급여보다 많은 사원들의 사번,이름(first_name),급여를 출력하시오.
   
                  
3) 급여평균보다 급여를 적게받는 사원들중 커미션을 받는 사원들의 사번,이름(first_name),급여,커미션 퍼센트를 출력하시오.
    
    
4)각 부서의 최소급여가 20번 부서의 최소급여보다 많은 부서의 번호와 그부서의 최소급여를 출력하시오.
 
    
5) 사원번호가 177인 사원과 담당 업무가 같은 사원의 사원이름(first_name)과 담당업무(job_id)하시오.   

  
6) 최소 급여를 받는 사원의 이름(first_name), 담당 업무(job_id) 및 급여(salary)를 표시하시오(그룹함수 사용).

				
7)업무별 평균 급여가 가장 적은  업무(job_id)를 찾아 업무(job_id)와 평균 급여를 표시하시오.

					  
8) 각 부서의 최소 급여를 받는 사원의 이름(first_name), 급여(salary), 부서번호(department_id)를 표시하시오.


9)담당 업무가 프로그래머(IT_PROG)인 모든 사원보다 급여가 적으면서 
업무가 프로그래머(IT_PROG)가 아닌  사원들의 사원번호(employee_id), 이름(first_name), 
담당 업무(job_id), 급여(salary))를 출력하시오.
           

10)부하직원이 없는 모든 사원의 이름을 표시하시오.


/*===================================================
ROWNUM
1. oracle의 SELECT문 결과에 대해서 논리적인 일련번호를 부여한다.
2. ROWNUM은 조회되는 행수를 제한할 때 많이 사용한다.
3. rownum = 1, rownum <= 3, rownum < 3(가능)
   rownum = 3, rownum >= 3, rownum > 3(불가능)
=====================================================*/
SELECT rownum, first_name, salary
FROM employees; --O

SELECT rownum, first_name, salary
FROM employees
WHERE rownum = 1; --O

SELECT rownum, first_name, salary
FROM employees
WHERE rownum <= 3; --O


SELECT rownum, first_name, salary
FROM employees
WHERE rownum = 3; --X

SELECT rownum, first_name, salary
FROM employees
WHERE rownum >= 3; --X

SELECT b.*
FROM (SELECT rownum AS rm, a.*       --(.* : 모든 컬럼의 데이터 값을 말함)
      FROM (SELECT * FROM employees
            ORDER BY salary DESC) a
      )b
WHERE b.rm >=6 AND b.rm <=10; -->=를 사용하지 못하기 때문에 변수를 지정해서 나타냄.

/*==================================================================
ROWID
1. oracle에서 데이터를 구분할 수 있는 유일한 값이다.
2. SELECT문에서 rowid를 사용할 수 있다.
3. rowid을 통해서 데이터가 어떤 데이터파일, 어느 블록에 저장되어 있는지 알 수 있다.
4. rowid 구조(총 18자리)
   오브젝트 번호(1~6) : 오브젝트 별로 유일한 값을 가지고 있으며, 해당 오브젝트가 속해 있는 값이다.
   파일 번호(7~9) : 테이블스페이스(tablespace)에 속해 있는 데이터 파일에 대한 상대 파일번호이다.
   블록 번호(10~15) : 데이터 파일 내부에서 어느 블록에 데이타가 있는지 알려준다.
   데이터 번호(16~18) : 데이터 블록에 데이터가 저장되어 있는 순서를 의미한다.

[block size 확인]~8kbyte가 저장됨
SQL> conn sys/a1234 as sysdba
Connencted
SQL> show user
USER is "SYS"
SQL> show parameter db_block_size

NAME                                TYPE            VALUE
--------------------------------------------------------------------
db_block_size                       integer         8192
====================================================================*/
SELECT rowid, first_name, salary
FROM employees;


















