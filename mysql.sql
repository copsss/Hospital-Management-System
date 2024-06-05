

-- 触发器控制下的添加操作
DELIMITER //

CREATE TRIGGER check_doctor_capacity
BEFORE INSERT ON Appointment
FOR EACH ROW
BEGIN
    DECLARE current_patient_count INT;
    DECLARE doctor_capacity INT;
    
    -- 查询当前医生已有的预约数
    SELECT COUNT(patient_id) INTO current_patient_count
    FROM Appointment
    WHERE doctor_id = NEW.doctor_id;
    
    -- 查询医生的最大接诊能力
    SELECT consult_capacity INTO doctor_capacity
    FROM Doctor
    WHERE doctor_id = NEW.doctor_id;
    
    -- 检查是否超出接诊能力
    IF current_patient_count >= doctor_capacity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor has reached the consultation capacity.';
    END IF;
END //

DELIMITER ;



-- 存储过程控制下的更新操作

DELIMITER //

CREATE PROCEDURE payBill(IN pat_id INT)
BEGIN
    DECLARE v_ward_id INT;
    DECLARE v_ward_type ENUM('1', '2', '3');
    DECLARE v_strt_date DATE;
    DECLARE v_end_date DATE;
    DECLARE v_no_of_days INT;
    DECLARE v_bill INT;
    DECLARE v_insurance DECIMAL(10, 2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 出现异常时回滚事务
        ROLLBACK;
        -- 重新引发异常
        RESIGNAL;
    END;

    -- 开始事务
    START TRANSACTION;

    -- 初始化账单和保险
    SET v_bill = 0;
    SET v_insurance = 0;

    -- 获取床位记录
    SELECT ward_id, COALESCE(date_in, CURDATE()), COALESCE(date_out, CURDATE()) INTO v_ward_id, v_strt_date, v_end_date
    FROM bed_record
    WHERE patient_id = pat_id
    LIMIT 1;

    -- 检查是否找到了记录
    IF v_ward_id IS NULL OR v_strt_date IS NULL OR v_end_date IS NULL THEN
        -- 记录未找到或日期无效，返回错误信息
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bed record not found or dates are invalid';
    END IF;

    -- 获取病房类型
    SELECT Ward_type INTO v_ward_type
    FROM wards
    WHERE ward_id = v_ward_id
    LIMIT 1;

    -- 检查是否找到了病房类型
    IF v_ward_type IS NULL THEN
        -- 记录未找到，返回错误信息
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ward type not found';
    END IF;

    -- 计算住院天数
    SET v_no_of_days = DATEDIFF(v_end_date, v_strt_date);

    -- 根据病房类型计算账单
    IF v_ward_type = '1' THEN
        SET v_bill = 500 * v_no_of_days;
    ELSEIF v_ward_type = '2' THEN
        SET v_bill = 400 * v_no_of_days;
    ELSEIF v_ward_type = '3' THEN
        SET v_bill = 300 * v_no_of_days;
    END IF;

    -- 计算医保报销金额
    IF v_bill > 500 THEN
        SET v_insurance = (v_bill - 500) * 0.70;
    ELSE
        SET v_insurance = 0.00;
    END IF;

    -- 更新床位记录
    UPDATE bed_record
    SET date_in = NULL, date_out = NULL, status = 'V', patient_id = NULL
    WHERE patient_id = pat_id;

    -- 更新 expenditure 表
    UPDATE expenditure
    SET total_expense = total_expense + v_bill, 
        insurance_coverage = insurance_coverage + v_insurance, 
        current_status = 'DISCHARGED'
    WHERE patient_id = pat_id;

    -- 提交事务
    COMMIT;

    -- 返回账单金额和医保报销金额
    SELECT v_bill AS bill, v_insurance AS insurance;

END //

DELIMITER ;

-- 含有视图的查询操作
CREATE VIEW AvailableBeds AS
SELECT * FROM Bed_record WHERE status = 'V';






