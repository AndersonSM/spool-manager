# spool-manager

Setup:
1. Caso o root não possua um crontab definido, inicie um com "sudo crontab -e"
e adicione um job qualquer, apenas para poder instalar
2. Execute o script install.sh

Imprimindo:
-O script print.sh deve ser usado no lugar do comando lp e aceita os mesmos parametros e opções

Informações sobre um usuário:
-O script print-info-user.sh deve ser usado passando dois parametros:
usuario e mês/ano
Ex: print-info-user.sh anderson 11/2018

Observações:
-O script possui uma limitação e imprime apenas um arquivo por vez.
Ex: Não é possível fazer "print.sh arquivo1 arquivo2"
