<?php

require_once __DIR__ . '/controllers/VooController.php';

$controller = new VooController();
$acao = $_GET['acao'] ?? 'listar';

switch ($acao) {
    case 'listar':
        $controller->listar();
        break;
    case 'salvar':
        $controller->salvar();
        break;
    case 'excluir':
        $controller->excluir();
        break;
    case 'lixeira':
        $controller->lixeira();
        break;
    case 'restaurar':
        $controller->restaurar();
        break;
    default:
        $controller->listar();
        break;
}
