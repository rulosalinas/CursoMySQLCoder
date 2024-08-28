-- ----------------- TRIGGERS --------------------------------------

USE colegioprimario;

-- 1: Verificar la capacidad del aula antes de la inscripción de los alunos

DROP TRIGGER IF EXISTS colegioprimario.VerificarCapacidadAula;
DELIMITER //
CREATE TRIGGER VerificarCapacidadAula
BEFORE INSERT ON inscripcion
FOR EACH ROW
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM inscripcion
    WHERE id_aula = NEW.id_aula;
    
    IF total >= (SELECT capacidad FROM aulas WHERE id_aula = NEW.id_aula) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay vacantes disponibles en el aula seleccionada';
    END IF;
END //
DELIMITER ;


-- 2: Actualizar vacantes libres al inscribir alumno

DROP TRIGGER IF EXISTS colegioprimario.ActualizarVacantesLibres;
DELIMITER //
CREATE TRIGGER ActualizarVacantesLibres
AFTER INSERT ON inscripcion
FOR EACH ROW
BEGIN
    UPDATE aulas
    SET vacantes_Lib = vacantes_Lib - 1
    WHERE id_aula = NEW.id_aula;
END //
DELIMITER ;

-- 3: Evitar duplicidad de DNI en la tabla de alumnos

DROP TRIGGER IF EXISTS colegioprimario.EvitarDuplicidadDniAlumno;
DELIMITER //
CREATE TRIGGER EvitarDuplicidadDniAlumno
BEFORE INSERT ON alumno
FOR EACH ROW
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM alumno
    WHERE dni = NEW.dni;
    
    IF total > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI ya está registrado para otro alumno';
    END IF;
END //
DELIMITER ;