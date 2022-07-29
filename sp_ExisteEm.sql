/*
Leia o README.md
*/
USE [master]
GO
IF ( OBJECT_ID('sp_ExisteEm') IS NOT NULL )
    DROP PROCEDURE [sp_ExisteEm]

CREATE PROCEDURE [dbo].[sp_ExisteEm]
(
    @Objeto VARCHAR(512) --nome do objeto que está procurando
)
AS
BEGIN
/*

    =================================================================
    SQL - Procedure sp_ExisteEm
    =================================================================
    Procedure de localizar objecto dentro do banco
    Locais procurados
    1 - Tabelas
    2 - Views
    3 - Trigger 
    4 - Funções
    5 - Procedures
    6 - Colunas
    7 - Jobs Sql Agent


*/    
    SET NOCOUNT ON 

    --Tabela do Resultado
    IF ( OBJECT_ID('tempdb..##lista_banco_localizado') > 0 )
    BEGIN
        DROP TABLE tempdb..##lista_banco_localizado
    END
    CREATE TABLE tempdb..##lista_banco_localizado(
        [nome_do_banco] [nvarchar](128) NULL,
        [name] [sysname] NULL,
        [id] [int]  NULL,
        [xtype] [char](2)  NULL,
        [uid] [smallint] NULL,
        [info] [smallint] NULL,
        [status] [int] NULL,
        [base_schema_ver] [int] NULL,
        [replinfo] [int] NULL,
        [parent_obj] [int] NULL,
        [crdate] [datetime] NULL,
        [ftcatid] [smallint] NULL,
        [schema_ver] [int] NULL,
        [stats_schema_ver] [int] NULL,
        [type] [char](2) NULL,
        [userstat] [smallint] NULL,
        [sysstat] [smallint] NULL,
        [indexdel] [smallint] NULL,
        [refdate] [datetime]  NULL,
        [version] [int] NULL,
        [deltrig] [int] NULL,
        [instrig] [int] NULL,
        [updtrig] [int] NULL,
        [seltrig] [int] NULL,
        [category] [int] NULL,
        [cache] [smallint] NULL
    )
    
    SET NOCOUNT OFF

    DECLARE 
    @vs_sql        VARCHAR(MAX)
    ,@vs_nome    VARCHAR(100)
    ,@vs_coluna varchar(50)

    --Script para apagar tabelas onde foram encontrados registros
    SET @vs_sql = 'drop table tempdbm..##lista_banco_? '
    
    begin try
        --Realiza o loop em todos os bancos
        exec sp_MSforeachdb @vs_sql
    end try
    begin catch
        print 'Tabelas não existem'
    end catch

    SET @vs_sql = ''

    --Script para criar tabelas onde foram encontrados registros
    SET @vs_sql = 'select db_name() as [nome_do_banco], * into tempdbm..##lista_banco_? From ?..sysobjects where name like ''%'+ @Objeto+'%'''
    
    --Realiza o loop em todos os bancos
    exec sp_MSforeachdb @vs_sql

    DECLARE cr_lista INSENSITIVE CURSOR FOR 
    SELECT name 
      FROM tempdb..sysobjects
    where name like '##lista_banco_%'
       and name != '##lista_banco_localizado'

    OPEN cr_lista

    FETCH NEXT FROM cr_lista INTO @vs_nome

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        
        SET @vs_coluna = ''
        SET @vs_coluna =  LTRIM(RTRIM(REPLACE(convert(varchar(50),@vs_nome),'##lista_banco_','')))
        

        SET @vs_sql = ''
        SET @vs_sql = 'UPDATE ' + @vs_nome + ' SET [nome_do_banco] = ' +char(39)+ REPLACE(@vs_coluna,'##','') +char(39)
        
        EXECUTE (@vs_sql)    

        SET @vs_sql = ''
        SET @vs_sql = 'INSERT INTO tempdb..##lista_banco_localizado SELECT * FROM ' +@vs_nome + ' WHERE nome_do_banco IS NOT NULL'
        EXECUTE (@vs_sql)
        
        SET @vs_sql = ' DROP TABLE '+@vs_nome
        EXECUTE (@vs_sql)
        
        FETCH NEXT FROM cr_lista INTO @vs_nome
    END
    CLOSE cr_lista
    DEALLOCATE cr_lista

     
    --2 - Views
    --3 - Trigger 
    --4 - Funções
    --5 - Procedures
    -- Verifica dentro de procedures, views, trigger e funções
    SET @vs_sql = 
    'SELECT 
        db_name() as [nome_do_banco]
        ,sysobjects.xtype
        ,sysobjects.Name Nome
        into tempdb..##lista_banco_?
    FROM 
        ?..syscomments (nolock) 
        Inner Join ?..sysobjects (nolock) On sysobjects.ID = syscomments.ID
    Where 
        syscomments.text like ''%' + LTRIM(RTRIM(@Objeto)) + '%'''
    
    --Realiza o loop em todos os bancos
    exec sp_MSforeachdb @vs_sql
    
    DECLARE cr_lista INSENSITIVE CURSOR FOR 
    SELECT name 
      FROM tempdb..sysobjects
    where name like '##lista_banco_%'
       and name != '##lista_banco_localizado'

     OPEN cr_lista

     FETCH NEXT FROM cr_lista INTO @vs_nome

     WHILE (@@FETCH_STATUS = 0)
     BEGIN
        
        SET @vs_coluna = ''
        SET @vs_coluna =  LTRIM(RTRIM(REPLACE(convert(varchar(50),@vs_nome),'lista_banco_','')))
        

        SET @vs_sql = ''
        SET @vs_sql = 'UPDATE ' + @vs_nome + ' SET [nome_do_banco] = ' +char(39) + REPLACE(@vs_coluna,'##','') +char(39)
        
        EXECUTE (@vs_sql)    

        SET @vs_sql = ''
        SET @vs_sql = 'INSERT INTO tempdb..##lista_banco_localizado (nome_do_banco,xtype,name) SELECT [nome_do_banco],xtype,Nome FROM ' +@vs_nome + ' WHERE nome_do_banco IS NOT NULL'
        EXECUTE (@vs_sql)
        
        SET @vs_sql = ' DROP TABLE '+@vs_nome
        EXECUTE (@vs_sql)
        
        FETCH NEXT FROM cr_lista INTO @vs_nome
     END
     CLOSE cr_lista
     DEALLOCATE cr_lista
    
    
    --6 - Colunas
    --Verifica em nomes de colunas
    SET @vs_sql = 
    'SELECT 
        db_name() as [nome_do_banco]
        ,sysobjects.xtype
        ,sysobjects.Name Nome
        into tempdb..##lista_banco_?
    FROM 
        ?..syscolumns (nolock)  Inner Join 
        ?..sysobjects (nolock) On sysobjects.ID = syscolumns.ID
    Where  syscolumns.name like ''%' + LTRIM(RTRIM(@Objeto)) + '%'''
    
    --Realiza o loop em todos os bancos
    exec sp_MSforeachdb @vs_sql
    
    DECLARE cr_lista INSENSITIVE CURSOR FOR 
    SELECT name 
      FROM tempdb..sysobjects
    where name like '##lista_banco_%'
       and name != '##lista_banco_localizado'

     OPEN cr_lista

     FETCH NEXT FROM cr_lista INTO @vs_nome

     WHILE (@@FETCH_STATUS = 0)
     BEGIN
        
        SET @vs_coluna = ''
        SET @vs_coluna =  LTRIM(RTRIM(REPLACE(convert(varchar(50),@vs_nome),'lista_banco_','')))
        

        SET @vs_sql = ''
        SET @vs_sql = 'UPDATE ' + @vs_nome + ' SET [nome_do_banco] = ' +char(39)+ REPLACE(@vs_coluna,'##','') +char(39)
        
        EXECUTE (@vs_sql)    

        SET @vs_sql = ''
        SET @vs_sql = 'INSERT INTO tempdb..##lista_banco_localizado (nome_do_banco,xtype,name) SELECT [nome_do_banco],xtype,Nome FROM ' +@vs_nome + ' WHERE nome_do_banco IS NOT NULL'
        EXECUTE (@vs_sql)
        
        SET @vs_sql = ' DROP TABLE '+@vs_nome
        EXECUTE (@vs_sql)
        
        FETCH NEXT FROM cr_lista INTO @vs_nome
     END
     CLOSE cr_lista
     DEALLOCATE cr_lista

     
     --Novidade
     --7 - Jobs Sql Agent
     --Verifica nos jobs agendados no sql
     SET @vs_sql = ''
        SET @vs_sql = '
     INSERT INTO tempdb..##lista_banco_localizado (nome_do_banco,xtype,name)
     SELECT a.name, ''J'',b.step_name
       FROM 
        msdb..sysjobs a
        inner join msdb..sysjobsteps b on ( a.job_id = b.job_id )
     WHERE b.command like ''%' + LTRIM(RTRIM(@Objeto)) + '%'''
    
    begin try
        EXECUTE (@vs_sql)
    end try
    begin catch
        print 'Erro ao tentar ver os jobs agendados'
    end catch
    
    SELECT DISTINCT 
        NomeBanco    = nome_do_banco
        ,NomeTabela = name
        ,Tipo = Case
          WHEN (xtype = 'P')  THEN 'Stored Procedure'
          WHEN (xtype = 'V')  THEN 'View'
          WHEN (xType = 'TR') THEN 'Trigger'
          WHEN (xType = 'FN') THEN 'Função'
          WHEN (xType = 'U')  THEN 'Tabela'
          WHEN (xType = 'J')  THEN 'Job' --Novidade
          ELSE 'Outros' end 
    FROM 
        tempdb..##lista_banco_localizado
    ORDER BY nome_do_banco,Tipo Desc,name


    DROP TABLE tempdb..##lista_banco_localizado

    --Script para apagar tabelas onde foram encontrados registros
    SET @vs_sql = 'drop table tempdbm..##lista_banco_? '
    
    begin try
        --Realiza o loop em todos os bancos
        exec sp_MSforeachdb @vs_sql
    end try
    begin catch
        print 'Tabelas apagadas'
    end catch
END
GO