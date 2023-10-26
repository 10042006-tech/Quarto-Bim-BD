use aula_22B_20231025;

CREATE DATABASE exercicios_trigger;
USE exercicios_trigger;


CREATE TRIGGER insere_auditoria
AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem) VALUES ('Novo cliente inserido em ' || datetime('now'));
END;
//
    
CREATE TRIGGER tentativa_exclusao_cliente_auditoria
BEFORE DELETE ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem) VALUES ('Tentativa de exclusão de cliente em ' || datetime('now'));
END;
//
CREATE TRIGGER atualiza_nome_cliente_auditoria
AFTER UPDATE ON Clientes
FOR EACH ROW
BEGIN
    IF NEW.nome != OLD.nome AND (NEW.nome IS NOT NULL AND NEW.nome != '') THEN
        INSERT INTO Auditoria (mensagem) VALUES ('Nome do cliente atualizado de ' || OLD.nome || ' para ' || NEW.nome || ' em ' || datetime('now'));
    END IF;
END;
//

CREATE TRIGGER impedir_nome_vazio_null
BEFORE UPDATE ON Clientes
FOR EACH ROW
BEGIN
    IF NEW.nome IS NULL OR NEW.nome = '' THEN
        INSERT INTO Auditoria (mensagem) VALUES ('Tentativa de atualização do nome para um valor vazio ou NULL em ' || datetime('now'));
        SELECT RAISE(ABORT, 'O nome do cliente não pode ser vazio ou NULL');
    END IF;
END;
//

CREATE TRIGGER decrementa_estoque
AFTER INSERT ON Pedidos
FOR EACH ROW
BEGIN
    UPDATE Produtos SET estoque = estoque - 1 WHERE id = NEW.produto_id;
    IF (SELECT estoque FROM Produtos WHERE id = NEW.produto_id) < 5 THEN
        INSERT INTO Auditoria (mensagem) VALUES ('Estoque do produto ' || (SELECT nome FROM Produtos WHERE id = NEW.produto_id) || ' abaixo de 5 unidades em ' || datetime('now'));
    END IF;
END;
//
