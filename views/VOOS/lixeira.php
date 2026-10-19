<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Voos Excluídos </title>
</head>
<body>
    <h1>Voos Excluídos </h1>
    
    <p>
        <a href="index.php?acao=listar">← Voltar para a Lista de Voos Ativos</a>
    </p>

    <table border="1" cellpadding="10">
        <thead>
            <tr>
                <th>Número do Voo</th>
                <th>Origem</th>
                <th>Destino</th>
                <th>Data de Partida</th>
                <th>Data da Exclusão</th>
                <th>Ações</th>
            </tr>
        </thead>
        <tbody>
            <?php if (!empty($voosExcluidos)): ?>
                <?php foreach ($voosExcluidos as $voo): ?>
                    <tr>
                        <td><?= htmlspecialchars($voo['num_voo']); ?></td>
                        <td><?= htmlspecialchars($voo['origem']); ?></td>
                        <td><?= htmlspecialchars($voo['destino']); ?></td>
                        <td><?= htmlspecialchars($voo['data_partida']); ?></td>
                        <td><?= htmlspecialchars($voo['deleted_at']); ?></td>
                        <td>
                            <a href="index.php?acao=restaurar&id=<?= $voo['id_VOO']; ?>" onclick="return confirm('Deseja restaurar este voo?')">Restaurar</a>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php else: ?>
                <tr>
                    <td colspan="6">Nenhum voo na lixeira.</td>
                </tr>
            <?php endif; ?>
        </tbody>
    </table>
</body>
</html>