with open("atividade-03-voos-do-aeroporto.txt", "r", encoding="utf-8") as arquivo:
    cabecalho = next(arquivo)
    
    print(f"{'ID': } {'Voo': } {'Destino': } {'Portao': } {'Horario': } {'Status'}")
    print("-" * 60)
    
    for linha in arquivo:
        id_voo, num_voo, destino, portao, horario, status = linha.strip().split(";")
        print(f"{id_voo: } {num_voo: } {destino: } {portao: } {horario: } {status}")
