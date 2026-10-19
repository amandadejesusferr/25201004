<?php

require_once __DIR__ . '/../models/VOO.php';

class VooController
{
    private Voo $voo;

    public function __construct()
    {
        $this->voo = new Voo();
    }

    public function listar(): void
    {
        $voos = $this->voo->listar();
        require __DIR__ . '/../views/voos/listar.php';
    }

    public function salvar(): void
    {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->voo->criar($_POST);
        }
        header('Location: index.php?acao=listar');
        exit;
    }

    public function excluir(): void
    {
        $id = (int) ($_GET['id'] ?? 0);
        if ($id > 0) {
            $usuarioId = $_SESSION['usuario_id'] ?? 1; 
            
            $this->voo->excluir($id, $usuarioId);
        }
        header('Location: index.php?acao=listar');
        exit;
    }

    public function lixeira(): void
    {
        $voosExcluidos = $this->voo->listarExcluidos();
        require __DIR__ . '/../views/voos/lixeira.php';
    }

    public function restaurar(): void
    {
        $id = (int) ($_GET['id'] ?? 0);
        if ($id > 0) {
            $this->voo->restaurar($id);
        }
        header('Location: index.php?acao=lixeira');
        exit;
    }
}