<?php

require_once __DIR__ . '/../config/database.php';

class Voo
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    public function listar(): array
    {
        $sql = "SELECT * FROM VOO ORDER BY data_partida";
        return $this->db->query($sql)->fetchAll();
    }

    public function buscar(int $id_voo): ?array
    {
        $stmt = $this->db->prepare("SELECT * FROM VOO WHERE id_VOO = :id_voo");
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

    public function excluir(int $id_voo): bool
    {
        $stmt = $this->db->prepare("DELETE FROM VOO WHERE id_VOO = :id_voo");
        return $stmt->execute([':id_voo' => $id_voo]);
    }
}