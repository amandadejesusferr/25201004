<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Lista de Voos</title>
</head>
<body>
    <h1>Lista de Voos Cadastrados </h1>

    <p>
        <a href="index.php?acao=lixeira">Ver Voos Excluídos </a>
    </p>

    <table border="1" cellpadding="10">
        <thead>
            <tr>
                <th>Número do Voo</th>
                <th>Origem</th>
                <th>Destino</th>
                <th>Data de Partida</th>
                <th>Data de Chegada</th>
                <th>Ações</th>
            </tr>
        </thead>
        <tbody>
            <?php if (!empty($voos)): ?>
                <?php foreach ($voos as $voo): ?>
                    <tr>
                        <td><?= htmlspecialchars($voo['num_voo']); ?></td>
                        <td><?= htmlspecialchars($voo['origem']); ?></td>
                        <td><?= htmlspecialchars($voo['destino']); ?></td>
                        <td><?= htmlspecialchars($voo['data_partida']); ?></td>
                        <td><?= htmlspecialchars($voo['data_chegada']); ?></td>
                        <td>
                            <a href="index.php?acao=excluir&id=<?= $voo['id_VOO']; ?>" onclick="return confirm('Deseja excluir este voo?')">Excluir</a>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php else: ?>
                <tr>
                    <td colspan="6">Nenhum voo cadastrado.</td>
                </tr>
            <?php endif; ?>
        </tbody>
    </table>
</body>
</html>