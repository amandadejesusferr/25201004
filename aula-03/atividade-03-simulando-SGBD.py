ARQUIVO_VOOS = "atividade-03-voos-do-aeroporto.txt"

def full_table_scan():
    try:
        with open(ARQUIVO_VOOS, "r", encoding="utf-8") as arquivo:
            cabecalho = next(arquivo)
    
            print(f"{'ID':<4} {'Voo':<6} {'Destino':<16} {'Portao':<6} {'Horario': <8} {'Status'}")
            print("-" * 60)
    
            for linha in arquivo:
                id_voo, num_voo, destino, portao, horario, status = linha.strip().split(";")
                print(f"{id_voo:<4} {num_voo:<6} {destino:<16} {portao:<6} {horario:<8} {status}")
                
    except FileNotFoundError:
        print("Arquivo não encontrado.")
        
        
def buscar_por_id():
    
    id_procurado = input("ID para procura: ")
    
    try:
        with open(ARQUIVO_VOOS, "r", encoding="utf-8") as arquivo:
            cabecalho = next(arquivo)
            
            for linha in arquivo:
                dados = linha.strip().split(";")
                
                id_voo = dados[0]
                
                if id_voo == id_procurado:
                    id_v, num, dest, port, hora, stat = dados
                    print(f"{'ID':<4} {'Voo':<6} {'Destino':<16} {'Portao':<6} {'Horario': <8} {'Status'}")
                    print("-" * 60)
                    print(f"{id_v:<4} {num:<6} {dest:<16} {port:<6} {hora:<8} {stat}")
                    return
                
        print("ID não encontrado no arquivo.")
                
    except FileNotFoundError:
            print("Arquivo não encontrado.")
            

def filtrar_voos():
    procurar_voo = input("Destino para procura: ")
    encontrou = False
    
    try:
        with open(ARQUIVO_VOOS, "r", encoding="utf-8") as arquivo:
            cabecalho = next(arquivo)
                    
            for linha in arquivo:
                dados = linha.strip().split(";")
                        
                dest_procurado = dados[2]
                        
                if dest_procurado.strip().lower() == procurar_voo.strip().lower():
                    if not encontrou:
                        print(f"\n{'Voo':<6} {'Horario': <8}")
                        print("-" * 20)
                        encontrou = True
                        
                    num_voo, horario = dados[1], dados[4]
                    print(f"{num_voo:<6} {horario:<8}")
                    
            if not encontrou:
                print("\n Nenhum voo encontrado para este destino.")
                        
    except FileNotFoundError:
        print("Arquivo não encontrado.")
        

def menu():
    while True:
        print("\n--- Gerenciamento de Voos ---")
        print("1 - Listar todos os voos")
        print("2 - Buscar voo por ID")
        print("3 - Filtrar voos por Destino")
        print("0 - Sair")
        
        opcao = input("\nEscolha uma opção: ")
        
        if opcao == "1":
            full_table_scan()
        elif opcao == "2":
            buscar_por_id()
        elif opcao == "3":
            filtrar_voos()
        elif opcao == "0":
            print("Sistema encerrado.")
            break
        
        else:
            print("Opção inválida!")
        
            
menu()
