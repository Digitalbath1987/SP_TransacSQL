USE tecnocob
GO

DECLARE                                    
		 @ID_CONTRATO                             INT
		,@DIRECCION                               VARCHAR(500)
		,@COMUNA								  VARCHAR(255)
		,@CIUDAD								  VARCHAR(255)	
		,@ID_PAIS								  INT	=	1
		,@ID_USUARIO                              INT	=	1
		,@FECHA_CARGA                             DATETIME = GETDATE()
		,@FECHA_REFRESCO                          DATETIME = GETDATE()
		,@ORIGEN_ANFITRION                        VARCHAR(07)	= 'CA'
		,@NRO_CARGA                               INT	=	'2219' -- NUMERO DE CARGA ID_EMPRESA + ID CENDENTE                             
		,@NRO_REGISTRO                            INT   =   0
		,@IDENTIFICADOR                           VARCHAR(255)
		,@ID_CEDENTE							  INT	     =  19	  -- 19 TNR	
		,@COD_EMPRESA							  VARCHAR(5) = 'TNR'	
		,@ID_DIRECCION_N1						  INT		= 0						 


DECLARE RECORRE_DIRECCION_TNR CURSOR FOR


	SELECT    	        CLI.IDENTIFICADOR
					   ,CON.ID_CONTRATO
	FROM				IBR_ALO_V2..CONTRATO	CON		WITH(NOLOCK)
	INNER JOIN			IBR_ALO_V2..CLIENTE		CLI		WITH(NOLOCK)
	ON					CON.ID_CLIENTE		 =  CLI.ID_CLIENTE
	WHERE				CLI.ID_CEDENTE		 =	@ID_CEDENTE



OPEN RECORRE_DIRECCION_TNR
FETCH NEXT FROM RECORRE_DIRECCION_TNR
INTO @IDENTIFICADOR,@ID_CONTRATO   
WHILE @@FETCH_STATUS = 0  
BEGIN


/*---------------------------------------------------------------------------------------*/
		 DECLARE RECORRE_DIRECCION_TECNO CURSOR FOR

					 SELECT 
					 DIR.fld_cal_dir,
					 COM.fld_nom_com,
					 CIU.fld_nom_ciu
	   				 FROM  tecnocob..tbl_dir_cli      DIR  WITH(NOLOCK)
					 INNER JOIN tecnocob..tbp_comunas COM  WITH(NOLOCK)
					 ON DIR.fld_cod_com = COM.fld_cod_com 
					 INNER JOIN tecnocob..tbp_ciudades CIU WITH(NOLOCK)
					 ON COM.fld_cod_ciu = CIU.fld_cod_ciu
			   		 WHERE  DIR.fld_rut_cli = right('00000000000'+ltrim(rtrim(@IDENTIFICADOR)),11)
					 AND DIR.fld_fte_dir = @COD_EMPRESA


		 OPEN RECORRE_DIRECCION_TECNO
		 FETCH NEXT FROM RECORRE_DIRECCION_TECNO
			INTO @DIRECCION,@COMUNA,@CIUDAD   
		 WHILE @@FETCH_STATUS = 0  
		 BEGIN

		SET @NRO_REGISTRO    = @NRO_REGISTRO +1

		SET @COMUNA			 = IBR_ALO_V2.dbo.HOMOLOGAR_DIRECCION(RTRIM(LTRIM(@COMUNA)),1,2) 

		SET @ID_DIRECCION_N1 = (SELECT ISNULL(N1.ID_DIRECCION_N1,1) FROM IBR_ALO_V2..DIRECCION_N1 N1 WITH(NOLOCK) WHERE N1.NOMBRE = @COMUNA)  
		
		
		SET @ID_DIRECCION_N1 = ISNULL(@ID_DIRECCION_N1,1) 		

			--	 EXEC IBR_ALO_V2.DBO.SP_CREATE_DIRECCION 
				   				SELECT 	      @ID_CONTRATO
                                             ,@ID_DIRECCION_N1
                                             ,@DIRECCION
                                             ,1
                                             ,1
                                             ,@ID_USUARIO
                                             ,@FECHA_CARGA
                                             ,@FECHA_REFRESCO
                                             ,@ORIGEN_ANFITRION
                                             ,@NRO_CARGA
                                             ,@NRO_REGISTRO
                                             ,0




		 PRINT 'PASANDO POR EL REGISTRO: ' + CAST(@NRO_REGISTRO AS VARCHAR) + ',' + CAST(@IDENTIFICADOR AS VARCHAR)  + ',' + CAST(@ID_CONTRATO AS VARCHAR) + ',' + CAST(@DIRECCION AS VARCHAR)  + ',' + CAST(@COMUNA AS VARCHAR) 

		 FETCH NEXT FROM RECORRE_DIRECCION_TECNO
			INTO @DIRECCION,@COMUNA,@CIUDAD     
		 END
		 CLOSE RECORRE_DIRECCION_TECNO
		 DEALLOCATE RECORRE_DIRECCION_TECNO			 
/*-----------------------------------------------------------------------------------------------*/


FETCH NEXT FROM RECORRE_DIRECCION_TNR
INTO @IDENTIFICADOR,@ID_CONTRATO  
END
CLOSE RECORRE_DIRECCION_TNR
DEALLOCATE RECORRE_DIRECCION_TNR


