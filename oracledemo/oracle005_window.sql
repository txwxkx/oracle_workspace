--oracle005_window.sql
/*=================================
ROLLUP( )함수, CUBE( )함수
===================================*/
SELECT department_id, job_id, count(*)
FROM employees
GROUP BY department_id, job_id
ORDER BY department_id, job_id;

/*
ROLLUP구문은 GROUP BY 절과 같이 사용 되며, GROUP BY절에 의해서 
그룹 지어진 집합 결과에 대해서 좀 더 상세한 정보를 반환하는 기능을 수행 한다.
SELECT절에 ROLLUP을 사용함으로써 보통의 SELECT된 데이터와 그 데이터의 총계를 구할 수 있다.

ROLLUP(column1, column2)
(column1, column2)
(column1)
( )

ROLLUP(department_id, job_id)
20	MK_MAN 	 1   --그룹
20	MK_REP 	 1   --그룹
20           2   --그룹
           107   --총계
*/
SELECT department_id, count(*)
FROM employees
GROUP BY ROLLUP(department_id)
ORDER BY department_id;

SELECT department_id, job_id, count(*)
FROM employees
GROUP BY ROLLUP(department_id, job_id)
ORDER BY department_id, job_id;


/*
ROLLUP 함수는 소계와 합계를 순서에 맞게 반환하지만 
CUBE 함수는 계산 가능한 모든 소계와 합계를 반환한다.

CUBE( )함수
CUBE(column1, column2)
    (column1, column2)
    (column1)
    (column2)
    ( ) 전체
    
CUBE(department_id, job_id)
20	MK_MAN	 1   --그룹
20	MK_REP	 1   --그룹
20	    	 2   --소계
	MK_MAN	 1   --소계
	MK_REP	 1   --소계
           107   --총계
*/
SELECT department_id, count(*)
FROM employees
GROUP BY CUBE(department_id)
ORDER BY department_id;

SELECT department_id, job_id, count(*)
FROM employees
GROUP BY CUBE(department_id, job_id)
ORDER BY department_id, job_id;

SELECT department_id, job_id, count(*)
FROM employees
GROUP BY CUBE((department_id, job_id)) 
--괄호로 묶어준다는 것은 (department_id, job_id)를 하나로 본다는 뜻.
--출력을 하나로하되 총계가 나오게함
ORDER BY department_id, job_id;

/*
GROUPING 함수는 ROLLUP, CUBE에 모두 사용할 수 있다.
GROUPING 함수는 해당 Row가 GROUP BY에 의해서 산출된 Row인 경우에는 0을 반환하고, 
ROLLUP이나 CUBE에 의해서 산출된 Row인 경우에는 1을 반환하게 된다.
따라서 해당 Row가 결과집합에 의해 산출된 Data 인지, 
ROLLUP이나 CUBE에 의해서 산출된 Data 인지를 알 수 있도록 지원하는 함수이다.

GROUPING SETS( )함수
*/
SELECT department_id, job_id, count(*)
FROM employees
GROUP BY GROUPING SETS(department_id, job_id)
ORDER BY department_id, job_id;

SELECT department_id, job_id, count(*)
FROM employees
GROUP BY GROUPING SETS(department_id), GROUPING SETS(job_id)
ORDER BY department_id, job_id;

--SELECT CASE department_id
--            WHEN 10 THEN 'A'
--            WHEN 20 THEN 'B'
--            WHEN 30 THEN 'C'
--            ELSE 'D'
--            END AS "Alias"
--FROM employees;

SELECT CASE GROUPING(d.department_name)
            WHEN 1 THEN 'ALL Departments'
            ELSE d.department_name
            END AS "DNAME"
FROM departments d
GROUP BY ROLLUP(d.department_name);

SELECT d.department_name, count(*)
FROM departments d
GROUP BY ROLLUP(d.department_name);

SELECT GROUPING(d.department_name)
FROM departments d
GROUP BY ROLLUP(d.department_name);

SELECT CASE GROUPING(d.department_name)
            WHEN 1 THEN 'ALL Departments'
            ELSE d.department_name
            END AS "DNAME"
FROM departments d
GROUP BY ROLLUP(d.department_name);

SELECT CASE GROUPING(d.department_name)
            WHEN 1 THEN 'ALL Departments'
            ELSE d.department_name
       END AS "DNAME",
            
       CASE GROUPING(e.job_id)
            WHEN 1 THEN 'ALL Jobs'
            ELSE e.job_id
       END AS "JOB",
       count(*) AS "Total Sal",
       sum(e.salary) AS "Total Sal"
FROM departments d, employees e
GROUP BY ROLLUP(d.department_name, e.job_id);

/*=======================================================
그룹 내 순위 관련 함수
RANK( ) OVER( ) : 특정 컬럼에 대한 순위를 구하는 함수로 동일한 값에 대해서는 동일한 순위를 준다.
DENSE_RANK( ) OVER( ) : 동일한 순위가 하나의 건수로 취급한다.
ROW_NUMBER( ) OVER( ) : 동일한 값이라도 고유한 순위를 부여한다.
=========================================================*/
SELECT job_id, first_name, salary, rank() over(ORDER BY salary DESC)
FROM employees; -- 1 2 2 4 (동일한 순위를 준 만큼 밀려남)

--그룹별로 순위를 부여할 때 사용 : PARTITION BY
SELECT job_id, first_name, salary, rank() over(PARTITION BY job_id ORDER BY salary DESC)
FROM employees; -- 1 1 1 ... 1 2 3 4 5 ... (PARTITION BY)

SELECT job_id, first_name, salary, dense_rank() over(ORDER BY salary DESC)
FROM employees; -- 1 2 2 3

SELECT job_id, first_name, salary, row_number() over(ORDER BY salary DESC)
FROM employees;

/*==============================================================================
 계층형 질의
 1. START WITH 절은 계층구조 전개이 시작 위치를 지정하는 구문이다. 
 2. CONNECT BY 절은 다음에 전개될 자식 데이터를 지정하는 구문이다. 
 3. 루트 데이터는 LEVEL 1이다. (0이 아님) (의사컬럼)
    (1)CONNECT_BY_ROOT(의사컬럼)  
       - 현재 조회된 최상위 정보 
    (2)CONNECT_BY_ISLEAF(의사컬럼) 
       - 현재 행이 마지막 계층의 데이터인지 확인 
       - LEAF을 만나면 1을 반환하고 0을 반환
    (3) SYS_CONNECT_BY_PATH( 컬럼, 구분자)(의사컬럼)
        - 루트 노드부터 해당 행까지의 경로를 입력한 컬럼기준으로 구분자를 사용해서 보여줌  
    (4)CONNECT_BY_ISCYCLE(의사컬럼)  
       - 현재 행의 조상이기도 한 자식을 갖는 경우 1을 반환 
       - 이 의사컬럼을 사용하기 위해서 CONNECT BY다음에 NOCYCLE을 사용해야한다.
 4. PRIOR 자식 = 부모 (부모->자식 방향으로 전개. 순방향 전개)
    PRIOR 부모 = 자식 (자식->부모 방향으로 전개. 역방향 전개)
================================================================================*/
SELECT first_name, lpad(first_name, 10)
FROM employees;

SELECT first_name, lpad(first_name, 10, '*')
FROM employees;

--매너저 -> 사원
SELECT employee_id, manager_id, LEVEL, lpad(' ', 3*(LEVEL-1)) || first_name
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

--사원 -> 매니저
SELECT employee_id, manager_id, LEVEL, lpad(' ', 3*(LEVEL-1)) || first_name
FROM employees
START WITH manager_id IS NOT NULL
CONNECT BY PRIOR manager_id = employee_id;

--CONNECT_BY_ROOT : 최상위 루트
SELECT employee_id, manager_id, LEVEL, lpad(' ', 3*(LEVEL-1)) || first_name,
       CONNECT_BY_ROOT employee_id
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;


--CONNECT_BY_ISLEAF : 제일 하위이면 1, 아니면 0으로 리턴한다.
SELECT employee_id, manager_id, LEVEL, lpad(' ', 3*(LEVEL-1)) || first_name,
       CONNECT_BY_ROOT employee_id, CONNECT_BY_ISLEAF
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

--ORDER SIBLINGS BY : 레벨 단위로 정렬해줌
SELECT employee_id, manager_id, LEVEL, lpad(' ', 3*(LEVEL-1)) || first_name,
       CONNECT_BY_ROOT employee_id, CONNECT_BY_ISLEAF, SYS_CONNECT_BY_PATH(first_name, '/')
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id
ORDER SIBLINGS BY first_name;

--CONNECT_BY_ISCYCLE : 행이 자식노드를 가지고 있는데 다시 부모노드 인지를 찾아주는 함수로
--                     자식노드가 있으면 1, 없으면 0을 리턴한다.
                       
CREATE TABLE dept(
dept_id number(10),
dept_name varchar2(50),
parent_id number(10));

INSERT INTO dept
VALUES(10, '기획부', 200);

INSERT INTO dept
VALUES(20, '영업부', 100);

INSERT INTO dept
VALUES(200, '총괄', 10);

SELECT * FROM dept;

--ORA-01436: CONNECT BY loop in user data(무한 루프로 돌아가고 있음)
SELECT dept_id, LEVEL, lpad(' ', 3*(LEVEL-1)) || dept_name,
       parent_id
FROM dept
START WITH dept_id = 10
CONNECT BY PRIOR dept_id = parent_id;

--무한 루프로 돌아가는 행을 체크
SELECT dept_id, LEVEL, lpad(' ', 3*(LEVEL-1)) || dept_name,
       CONNECT_BY_ISCYCLE, parent_id
FROM dept
START WITH dept_id = 10
CONNECT BY NOCYCLE PRIOR dept_id = parent_id;



