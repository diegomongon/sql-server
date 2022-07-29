/*
===================================================================================================
Com esse sp_ExisteEm roda no master o usuários "comuns" precisam de acessos leitura e execução 
dessa procedure no master.

Abra o SSMS (Sql Server Management Studio)

1. Security -> Logins -> 
    No grupo ou usuário clica com o botão direito do mouse e vai em "Properties"
    "User Mapping" -> assinale master -> "Default Schema" - coloque "dbo" -> OK
2. Dabase -> System DataBase -> master -> Programmability -> stored procedure -> 
    Com o botão direito do mouse vai em "Propreties" -> 
    "Permissions" -> adicione o grupo ou usuário 
    Mas que opção Grant na linha do Execute


O processo de criação e permissão desse ser executado pelo administrador do banco.
===================================================================================================

Proceso via código sendo criado.

...
*/

