<?php

require_once __DIR__ . '/../config/database.php';

class Voo
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::conectar();
    }

    public function listar(): array
    {
        $sql = "SELECT * FROM VOO WHERE deleted_at IS NULL ORDER BY data_partida";
        return $this->db->query($sql)->fetchAll();
    }

    public function listarExcluidos(): array
    {
        $sql = "SELECT * FROM VOO WHERE deleted_at IS NOT NULL ORDER BY deleted_at DESC";
        return $this->db->query($sql)->fetchAll();
    }

    public function buscar(int $id_voo): ?array
    {
        $stmt = $this->db->prepare("SELECT * FROM VOO WHERE id_VOO = :id_voo AND deleted_at IS NULL");
        $stmt->execute([':id_voo' => $id_voo]);
        $voo = $stmt->fetch();

        return $voo ?: null;
    }

    public function criar(array $dados): bool
    {
        $sql = "INSERT INTO VOO (num_voo, origem, destino, data_partida, data_chegada, id_AERONAVE) 
                VALUES (:num_voo, :origem, :destino, :data_partida, :data_chegada, :id_AERONAVE)";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':num_voo'       => $dados['num_voo'],
            ':origem'        => $dados['origem'],
            ':destino'       => $dados['destino'],
            ':data_partida'  => $dados['data_partida'],
            ':data_chegada'  => $dados['data_chegada'],
            ':id_AERONAVE'   => $dados['id_AERONAVE'],
        ]);
    }

    public function excluir(int $id_voo, ?int $usuarioId = null): bool
    {
        try {
            $this->db->beginTransaction();

            $stmtBusca = $this->db->prepare("SELECT * FROM VOO WHERE id_VOO = :id_voo AND deleted_at IS NULL");
            $stmtBusca->execute([':id_voo' => $id_voo]);
            $voo = $stmtBusca->fetch(PDO::FETCH_ASSOC);

            if (!$voo) {
                throw new Exception("Voo não encontrado ou já excluído.");
            }

            $sqlDelete = "UPDATE VOO SET deleted_at = NOW() WHERE id_VOO = :id_voo";
            $stmtStmt = $this->db->prepare($sqlDelete);
            $stmtStmt->execute([':id_voo' => $id_voo]);

            $sqlAuditoria = "INSERT INTO auditoria (tabela, registro_id, acao, usuario_id, dados_antes) 
                             VALUES (:tabela, :registro_id, :acao, :usuario_id, :dados_antes)";
            $stmtAuditoria = $this->db->prepare($sqlAuditoria);
            $stmtAuditoria->execute([
                'tabela'      => 'VOO',
                'registro_id' => $id_voo,
                'acao'        => 'SOFT_DELETE',
                'usuario_id'  => $usuarioId,
                'dados_antes' => json_encode($voo)
            ]);

            $this->db->commit();
            return true;

        } catch (Exception $e) {
            $this->db->rollBack();
            return false;
        }
    }

    public function restaurar(int $id_voo): bool
    {
        $stmt = $this->db->prepare("UPDATE VOO SET deleted_at = NULL WHERE id_VOO = :id_voo");
        return $stmt->execute([':id_voo' => $id_voo]);
    }
}
