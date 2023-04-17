-- sample3.sql


-- ******************************************************
-- SELECT 문의 기본구조와 각 절의 실행순서
-- ******************************************************
--  - Clauses -                 - 실행순서 -
--
-- SELECT clause                    (5)
-- FROM clause                      (1)
-- WHERE clause                     (2)
-- GROUP BY clause                  (3)
-- HAVING clause                    (4)
-- ORDER BY clause                  (6)
-- ******************************************************


-- ------------------------------------------------------
-- 1. 단일(행) (반환)함수
-- ------------------------------------------------------
-- 단일(행) (반환)함수의 구분:
--
--  (1) 문자 (처리)함수 : 문자와 관련된 특별한 조작을 위한 함수
--  (2) 숫자 (처리)함수 : 
--  (3) 날짜 (처리)함수 : 날짜 데이터 타입 컬럼에 사용하기 위한 함수
--      a. SYSDATE          - DB서버에 설정된 날짜를 반환
--      b. MONTH_BETWEEN    - 두 날짜 사이의 월수를 계산하여 반환
--      c. ADD_MONTHS       - 특정 개월수를 더한 날짜를 계산하여 반환
--                          - 음수값을 지정하면 뺀 날짜를 반환
--      d. NEXT_DAY         - 명시된 날짜로부터, 다음 요일에 대한 날짜 반환
--      e. LAST_DAY         - 지정된 월의 마지막 날짜 반환
--                          - 윤년 및 평년 모두 자동으로 계산
--      f. ROUND            - 날짜를 가장 가까운 년도 또는 월로 반올림하여 
--                            반환
--      g. TRUNC            - 날짜를 가장 가까운 년도 또는 월로 절삭하여 반환
--
--      * Oracle은 날짜정보를 내부적으로 7바이트 숫자로 관리 -> 산술연산가능
--  (4) 변환 (처리)함수
--  (5) 일반 (처리)함수
--
--  단일(행) (반환)함수는, 테이블의 행 단위로 처리됨!
-- ------------------------------------------------------

-- ------------------------------------------------------
-- (0) 현 Oracle 서버의 날짜표기형식(DATE FORMAT) 설정확인
-- ------------------------------------------------------
-- Oracle NLS: National Language Support
-- 오라클의 년도표기 방식 (page 41 ~ 42 참고)
-- ------------------------------------------------------
DESC nls_session_parameters;

-- 아래의 SQL 문장을 SQL*Developer 에서도 수행해 볼 것!
SELECT
    *
FROM
    nls_session_parameters;    -- NLS_DATE_FORMAT 항목

ALTER SESSION SET nls_date_format = 'YYYY/MM/DD - HH24:MI:SS';

SELECT
    --sysdate,          -- 잊어버리라!!! (Local DB이든, Cloud DB이든)
    --systimestamp,     -- 잊어버리라!!! (Local DB이든, Cloud DB이든)
    current_date,
    current_timestamp
FROM
    dual;

-- ------------------------------------------------------
-- * To change Oracle's default date format
-- ------------------------------------------------------
-- Oracle SQL*Developer 에서도 수행해볼 것!
-- ------------------------------------------------------
ALTER SESSION SET NLS_DATE_FORMAT = 'RR/MM/DD';  -- SQL*Developer format
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-RR'; -- VSCODE format
ALTER SESSION SET nls_date_format = 'YYYY/MM/DD - HH24:MI:SS'; -- Our format


SELECT
    current_date,
    current_timestamp
FROM
    dual;


-- ------------------------------------------------------
-- (1) 날짜 (처리)함수 - SYSDATE(Deprecated) => current_date
-- ------------------------------------------------------
-- DB서버에 설정된 날짜를 반환
-- ------------------------------------------------------
SELECT
    current_date
FROM
    dual;


-- * 날짜 연산 (page 43참고)
-- (1) 날짜 + 숫자          : 날짜에 일수를 더하여 반환
-- (2) 날짜 - 숫자          : 날짜에 일수를 빼고 반환
-- (3) 날짜 - 날짜          : 두 날짜의 차이(일수) 반환
-- (4) 날짜 + 숫자/24       : 날짜에 시간을 더한다
-- (5) 날짜 + 숫자/24/60    : 날짜에 분을 더한다
-- (6) 날짜 + 숫자/24/60/60 : 날짜에 초를 더한다

SELECT
    current_date     AS 오늘,           -- (1)
    current_date + 1 AS 내일,           -- (2)
    -- current_date * 3,                -- XX
    -- current_date / 3,                -- XX
    current_date - 1 AS 어제,           -- (3)
    current_date - (current_date - 1),  -- (4)
    current_date + 3/24,                -- (5)
    current_date + 3/24/60,             -- (6)
    current_date + 3/24/60/60           -- (7)
FROM
    dual;


SELECT
    last_name,
    hire_date,
    current_date - hire_date AS 근속일수,            -- 현재날짜 - 입사일자 = 근속기간(일수)
    (current_date - hire_date) / 365 AS 근속기간,    -- 근속기간(일수) / 365 = 근속년수(소숫점포함)
    trunc( (current_date - hire_date) / 365 ) AS 근속년수
FROM
    employees
ORDER BY
    근속일수 DESC;     -- sort by column index 


-- ------------------------------------------------------
-- (2) 날짜 (처리)함수 - MONTHS_BETWEEN
-- ------------------------------------------------------
-- 두 날짜 사이의 월수를 계산하여 반환
-- ------------------------------------------------------
SELECT
    last_name,
    hire_date,
    months_between(current_date, hire_date) AS "근속월수(소숫점포함)",
    trunc( months_between(current_date, hire_date) ) AS "근속월수",
    trunc( months_between(current_date, hire_date) / 12 ) AS "근속년수"
FROM
    employees
ORDER BY
    "근속월수(소숫점포함)" DESC; -- sort by column index


-- ------------------------------------------------------
-- (3) 날짜 (처리)함수 - ADD_MONTHS
-- ------------------------------------------------------
-- 특정 개월수를 현재 날짜에 더한 날짜를 계산하여 반환
-- 음수값을 지정하면, 현재날짜에 지정된 개월수만큼 뺀 날짜를 반환
-- ------------------------------------------------------
SELECT
    current_date AS 오늘,
    add_months(current_date, 1) AS "1개월후 오늘",   -- 현재날짜 + 1개월
    add_months(current_date,-1) AS "1개월전 오늘"    -- 현재날짜 - 1개월
FROM
    dual;


-- ------------------------------------------------------
-- (4) 날짜 (처리)함수 - NEXT_DAY
-- ------------------------------------------------------
-- 명시된 날짜로부터, 다음 요일에 대한 날짜 반환
-- 일요일(1), 월요일(2) ~ 토요일(7)
-- ------------------------------------------------------
-- NEXT_DAY(date1, {'string' | n})
-- ------------------------------------------------------
SELECT
    last_name,
    hire_date,

    -- 최초로 돌아오는 금요일에 해당하는 날짜 출력
    next_day(hire_date, 'FRI'),
    -- next_day(hire_date, '금'),  -- ORA-01846: not a valid day of the week
    
    -- 최초로 돌아오는 금요일에 해당하는 날짜 출력
    next_day(hire_date, 6)
FROM
    employees
ORDER BY
    3 desc;


-- ------------------------------------------------------
-- (5) 날짜 (처리)함수 - LAST_DAY
-- ------------------------------------------------------
-- 지정된 월의 마지막 날짜 반환
-- 윤년 및 평년 모두 자동으로 계산
-- ------------------------------------------------------
-- LAST_DAY(date1)
-- ------------------------------------------------------
SELECT
    last_name,
    hire_date,

    -- 입사일자가 속한 그 달의 마지막 날짜 반환
    last_day(hire_date)
FROM
    employees
ORDER BY
    2 desc;


SELECT
    last_name,
    hire_date,

    -- 입사일 기준, 5개월 후의 돌아오는 일요일의 날짜 반환
    next_day( add_months(hire_date, 5), 'SUN' ) AS DATE1,
    next_day( add_months(hire_date, 5), 1 ) AS DATE2

    -- ORA-01846: not a valid day of the week
    -- next_day( add_months(hire_date, 5), '일' )
FROM
    employees
ORDER BY
    hire_date desc;



-- ------------------------------------------------------
-- (6) 날짜 (처리)함수 - ROUND
-- ------------------------------------------------------
-- 날짜를 가장 가까운 년도 또는 월로 반올림하여 반환
-- ------------------------------------------------------
-- ROUND(date1, 'YEAR') : 지정된 날짜의 년도를 반올림(to YYYY/01/01)
-- ROUND(date1, 'MONTH'): 지정된 날짜의 월을 반올림(to YYYY/MM/01)
-- ------------------------------------------------------
SELECT
    last_name,
    hire_date,

    -- 채용날짜의 년도를 반올림(to YYYY/01/01)
    round(hire_date,'YEAR'),
    
    -- 채용날짜의 월을 반올림(to YYYY/MM/01)
    round(hire_date,'MONTH')
FROM
    employees;


-- ------------------------------------------------------
-- (7) 날짜 (처리)함수 - TRUNC
-- ------------------------------------------------------
-- 날짜를 가장 가까운 년도 또는 월로 절삭하여 반환
-- ------------------------------------------------------
-- TRUNC(date1, 'YEAR') : 지정된 날짜의 년도를 절삭(to YYYY/01/01)
-- TRUNC(date1, 'MONTH'): 지정되 날짜의 월을 절삭(to YYYY/MM/01)
-- ------------------------------------------------------
SELECT
    last_name,
    hire_date,

    -- 채용날짜의 년도를 가장 가까운 년도로 절삭(to YYYY/01/01)
    trunc(hire_date, 'YEAR'),
    
    -- 채용날짜의 년도를 가장 가까운 월로 절삭(to YYYY/MM/01)
    trunc(hire_date, 'MONTH')
FROM
    employees;
