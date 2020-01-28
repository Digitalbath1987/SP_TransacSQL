	USE tecnocob
	GO

	DECLARE                                    
					 @ID_CLIENTE               INT
					,@ID_USUARIO               INT
					,@ORIGEN_ANFITRION         VARCHAR(07)
					,@NRO_CARGA                INT
					,@NRO_REGISTRO             INT = 0
					,@IDENTIFICADOR            VARCHAR(255)
-------------------------------------------------------------------
					,@COD_USUARIO			  VARCHAR(255)
					,@RES_CLI				  INT
					,@ID_SUBRESPUESTA		  INT
					,@ID_RESPUESTA			  INT
					,@COMENTARIO			  VARCHAR(255)
					,@INTERACCION_DISCADOR    VARCHAR(255)
					,@FECHA_GESTION			  DATETIME
					


										 
	DECLARE RECORRE_CLIENTE_TNR CURSOR FOR


				SELECT    	        CLI.IDENTIFICADOR
								   ,CLI.ID_CLIENTE
				FROM				IBR_ALO_V2..CLIENTE		CLI		WITH(NOLOCK)
				WHERE				CLI.ID_CEDENTE		 =	19


	OPEN RECORRE_CLIENTE_TNR
	FETCH NEXT FROM RECORRE_CLIENTE_TNR
				INTO @IDENTIFICADOR,@ID_CLIENTE   
	WHILE @@FETCH_STATUS = 0  
	BEGIN
	/*----------------------------------------------------*/
			 DECLARE RECORRE_GESTIONES_TECNO CURSOR FOR

		
							SELECT              GES.FLD_COD_USU,  -- COD DE USUARIO
												GES.fld_res_cli,  -- SUBREPUESTA
												ges.fld_comenta,  -- COMENTARIO
												GES.IDLLAMADA,    -- INTERACCION DISCADOR
												GES.fld_fec_acc   -- FECHA ACCION
							FROM				tecnocob..tbl_historial                    GES WITH(NOLOCK)
							INNER JOIN			tecnocob..tbl_homologacion_gestiones_tnr   HOM WITH(NOLOCK)
							ON					GES.fld_res_cli     = HOM.fld_res_cli
							where               GES.fld_cod_emp			=		'TNR'
							AND					GES.FLD_COD_USU		   !=		'discador'
							AND					GES.idllamada          !=       ''
							AND					GES.fld_rut_cli			=		right('00000000000'+ltrim(rtrim(@IDENTIFICADOR)),11)
							AND                 CAST(GES.fld_fec_acc AS date)  < '20200123'

			 OPEN RECORRE_GESTIONES_TECNO
			 FETCH NEXT FROM RECORRE_GESTIONES_TECNO
				    INTO @COD_USUARIO,@RES_CLI,@COMENTARIO,@INTERACCION_DISCADOR,@FECHA_GESTION   
			 WHILE @@FETCH_STATUS = 0  
			 BEGIN

								 SET @NRO_REGISTRO    =   @NRO_REGISTRO + 1

								 SET @ID_USUARIO	  =  (SELECT ID_USUARIO 
														  FROM IBR_ALO_V2..USUARIO WITH(NOLOCK) 
														  WHERE LOGIN = @COD_USUARIO)

								 SET @ID_SUBRESPUESTA =  (SELECT ID_RESPUESTA 
														  FROM   IBR_ALO_V2..HOMOLOGACION_GESTION WITH(NOLOCK)
														  WHERE  FLD_RES_CLI = @RES_CLI)

					IF NOT EXISTS(SELECT 1 FROM IBR_ALO_V2..GESTION GES WITH(NOLOCK)
								  WHERE  GES.INTERACCION_DISCADOR = @INTERACCION_DISCADOR)
								  BEGIN

								 INSERT INTO IBR_ALO_V2..GESTION
								 (ID_CLIENTE       ,ID_USUARIO             ,  ID_SUB_RESPUESTA      , ID_TIPO_ACCION  
								 ,FECHA_GESTION    ,COMENTARIO             ,  INTERACCION_DISCADOR  , NRO_DEPENDIENTE)
								  VALUES
								 (@ID_CLIENTE      , @ID_USUARIO           , @ID_SUBRESPUESTA      , 1 ,
								  @FECHA_GESTION   ,@COMENTARIO            , @INTERACCION_DISCADOR , 0)
		            END


			 PRINT 'PASANDO POR EL REGISTRO: ' + CAST(@NRO_REGISTRO AS VARCHAR) + '' + @COMENTARIO

			 FETCH NEXT FROM RECORRE_GESTIONES_TECNO
				    			    INTO @COD_USUARIO,@RES_CLI,@COMENTARIO,@INTERACCION_DISCADOR,@FECHA_GESTION   
			 END
			 CLOSE RECORRE_GESTIONES_TECNO
			 DEALLOCATE RECORRE_GESTIONES_TECNO			 
	/*----------------------------------------------------*/
	FETCH NEXT FROM RECORRE_CLIENTE_TNR
				INTO @IDENTIFICADOR,@ID_CLIENTE 
	END
	CLOSE RECORRE_CLIENTE_TNR
	DEALLOCATE RECORRE_CLIENTE_TNR


	