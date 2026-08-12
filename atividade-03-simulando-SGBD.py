with open("atividade-03-voos-do-aeroporto.txt", "r", encoding="utf-8") as arquivo:
    cabecalho = next(arquivo)
    
    print(f"{'ID':<4} {'Voo':<6} {'Destino':<16} {'Portao':<6} {'Horario': <8} {'Status'}")
    print("-" * 60)
    
    for linha in arquivo:
        id_voo, num_voo, destino, portao, horario, status = linha.strip().split(";")
        print(f"{id_voo:<4} {num_voo:<6} {destino:<16} {portao:<6} {horario:<8} {status}")
