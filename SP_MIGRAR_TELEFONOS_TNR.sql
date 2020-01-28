USE tecnocob
GO

DECLARE                                    
		 @ID_CONTRATO                             INT
		,@DIRECCION                               VARCHAR(500)
		,@COD_AREA								  VARCHAR(50)
		,@NUM_TEL 								  VARCHAR(50)
		,@ID_PAIS								  INT	=	1
		,@ID_USUARIO                              INT	=	1
		,@FECHA_CARGA                             DATETIME = GETDATE()
		,@FECHA_REFRESCO                          DATETIME = GETDATE()
		,@ORIGEN_ANFITRION                        VARCHAR(07)	= 'CA'
		,@TIPO_TELEFONO							  VARCHAR(07)
		,@NRO_CARGA                               INT	=	'2219' -- NUMERO DE CARGA ID_EMPRESA + ID CENDENTE                             
		,@NRO_REGISTRO                            INT   =   0
		,@IDENTIFICADOR                           VARCHAR(255)
		,@ID_CEDENTE							  INT	     =  19	  -- 19 TNR	
		,@COD_EMPRESA							  VARCHAR(5) = 'TNR'	
		,@ID_DIRECCION_N1						  INT		= 0	
		,@NUMERO_TELEFONO_DICADOR				  VARCHAR(255)						 


DECLARE RECORRE_TELEFONO_TNR CURSOR FOR


	SELECT    	        CLI.IDENTIFICADOR
					   ,CON.ID_CONTRATO
	FROM				IBR_ALO_V2..CONTRATO	CON		WITH(NOLOCK)
	INNER JOIN			IBR_ALO_V2..CLIENTE		CLI		WITH(NOLOCK)
	ON					CON.ID_CLIENTE		 =  CLI.ID_CLIENTE
	WHERE				CLI.ID_CEDENTE		 =	@ID_CEDENTE



OPEN RECORRE_TELEFONO_TNR
FETCH NEXT FROM RECORRE_TELEFONO_TNR
INTO @IDENTIFICADOR,@ID_CONTRATO   
WHILE @@FETCH_STATUS = 0  
BEGIN


/*---------------------------------------------------------------------------------------------*/
		 DECLARE RECORRE_TELEFONO_TECNO CURSOR FOR

					SELECT 
					 TEL.FLD_COD_AREA
					,TEL.FLD_NUM_TEL
					FROM Tecnocob..tbl_telefonos TEL  WITH(NOLOCK)
					WHERE  TEL.fld_rut_cli = right('00000000000'+ltrim(rtrim(@IDENTIFICADOR)),11)

		 OPEN RECORRE_TELEFONO_TECNO
		 FETCH NEXT FROM RECORRE_TELEFONO_TECNO
			INTO @COD_AREA,@NUM_TEL 
		 WHILE @@FETCH_STATUS = 0  
		 BEGIN

		SET @NRO_REGISTRO    = @NRO_REGISTRO +1
		SET @NUMERO_TELEFONO_DICADOR = (SELECT REPLACE(FONO_DISCAR,' ','')  FROM IBR_ALO_V2..FN_CREATE_FONO_CL(@COD_AREA + @NUM_TEL))
		SET @TIPO_TELEFONO = CASE 
								 WHEN @COD_AREA = '9'         -- TIPO DE TELEFONO ? CELULAR : 2 FIJO : 1
								     THEN 2
								 ELSE 1
						     END

		 --  EXEC IBR_ALO_V2..SP_CREATE_TELEFONO
                  SELECT                 @ID_CONTRATO
                                        ,@NUM_TEL 
                                        ,@COD_AREA
                                        ,@NUM_TEL
								        ,@NUMERO_TELEFONO_DICADOR
                                        ,@TIPO_TELEFONO
                                        ,1
                                        ,1
                                        ,1
                                        ,@FECHA_CARGA
                                        ,@FECHA_REFRESCO
								        ,@ORIGEN_ANFITRION
                                        ,@NRO_CARGA
                                        ,@NRO_REGISTRO
										,0


		 PRINT 'PASANDO POR EL REGISTRO: ' + CAST(@NRO_REGISTRO AS VARCHAR) + ',' + CAST(@IDENTIFICADOR AS VARCHAR)  + ',' + CAST(@ID_CONTRATO AS VARCHAR) + ',' + CAST(@NUM_TEL AS VARCHAR) + ',' + @NUMERO_TELEFONO_DICADOR

		 FETCH NEXT FROM RECORRE_TELEFONO_TECNO
			INTO @COD_AREA,@NUM_TEL    

		 END
		 CLOSE RECORRE_TELEFONO_TECNO
		 DEALLOCATE RECORRE_TELEFONO_TECNO			 
/*----------------------------------------------------------------------------------------------------*/


FETCH NEXT FROM RECORRE_TELEFONO_TNR
INTO @IDENTIFICADOR,@ID_CONTRATO  
END
CLOSE RECORRE_TELEFONO_TNR
DEALLOCATE RECORRE_TELEFONO_TNR


