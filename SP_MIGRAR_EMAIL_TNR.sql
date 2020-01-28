USE tecnocob
GO

DECLARE                                    
@ID_CONTRATO                             INT
,@EMAIL                                   VARCHAR(100)
,@ID_USUARIO                              INT
,@FECHA_CARGA                             DATETIME = GETDATE()
,@FECHA_REFRESCO                          DATETIME = GETDATE()
,@ORIGEN_ANFITRION                        VARCHAR(07)
,@NRO_CARGA                               INT
,@NRO_REGISTRO                            INT = 0
,@IDENTIFICADOR                           VARCHAR(255)
										 


DECLARE RECORRE_EMAIL_TNR CURSOR FOR

	SELECT    	        CLI.IDENTIFICADOR
					   ,CON.ID_CONTRATO
	FROM				IBR_ALO_V2..CONTRATO	CON		WITH(NOLOCK)
	INNER JOIN			IBR_ALO_V2..CLIENTE		CLI		WITH(NOLOCK)
	ON					CON.ID_CLIENTE		 =  CLI.ID_CLIENTE
	WHERE				CLI.ID_CEDENTE		 =	19



OPEN RECORRE_EMAIL_TNR
FETCH NEXT FROM RECORRE_EMAIL_TNR
INTO @IDENTIFICADOR,@ID_CONTRATO   
WHILE @@FETCH_STATUS = 0  
BEGIN
/*----------------------------------------------------*/
		 DECLARE RECORRE_EMAIL_TECNO CURSOR FOR
				 SELECT fld_e_mail 
				 FROM   tbl_email WITH(NOLOCK)
				 WHERE  fld_rut_cli = right('00000000000'+ltrim(rtrim(@IDENTIFICADOR)),11)
		 OPEN RECORRE_EMAIL_TECNO
		 FETCH NEXT FROM RECORRE_EMAIL_TECNO
			INTO @EMAIL   
		 WHILE @@FETCH_STATUS = 0  
		 BEGIN

		SET @NRO_REGISTRO = @NRO_REGISTRO +1

					 --EXEC IBR_ALO_V2.DBO.SP_CREATE_EMAIL  
									SELECT 	 @ID_CONTRATO                             
										,@EMAIL                                  
										,1                                  
										,1                       
										,1                             
										,@FECHA_CARGA                         
										,@FECHA_REFRESCO                        
									  ,'CA'									   -- ORIGEN
									  ,'2219'							   	       -- NUMERO DE CARGA ID_EMPRESA + ID CENDENTE                             
										,@NRO_REGISTRO                            
										,0	

		 PRINT 'PASANDO POR EL REGISTRO: ' + CAST(@NRO_REGISTRO AS VARCHAR) + '' + @EMAIL

		 FETCH NEXT FROM RECORRE_EMAIL_TECNO
			 INTO @EMAIL    
		 END
		 CLOSE RECORRE_EMAIL_TECNO
		 DEALLOCATE RECORRE_EMAIL_TECNO			 
/*----------------------------------------------------*/
FETCH NEXT FROM RECORRE_EMAIL_TNR
INTO @IDENTIFICADOR,@ID_CONTRATO  
END
CLOSE RECORRE_EMAIL_TNR
DEALLOCATE RECORRE_EMAIL_TNR

















	



	