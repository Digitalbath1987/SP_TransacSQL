	USE tecnocob
	GO



/*----------------------------------------------------------------------*/
/*-						DECLARACION DE VARIABLES					   -*/
/*----------------------------------------------------------------------*/
	DECLARE                                    
					 @ID_CLIENTE               INT
					,@ID_USUARIO               INT
					,@ORIGEN_ANFITRION         VARCHAR(07)
					,@NRO_CARGA                INT
					,@NRO_REGISTRO             INT = 0
					,@IDENTIFICADOR            VARCHAR(255)
					,@COD_USUARIO			   VARCHAR(255)
					,@RES_CLI				   INT
					,@ID_SUBRESPUESTA		   INT
					,@ID_RESPUESTA			   INT
					,@COMENTARIO			   VARCHAR(255)
					,@INTERACCION_DISCADOR     VARCHAR(255)
					,@FECHA_GESTION			   DATETIME 

/*----------------------------------------------------------------------*/
/*-				CURSOR PARA TRASPASO DE GESTIONES DIARIAS			   -*/
/*----------------------------------------------------------------------*/
			 DECLARE RECORRE_GESTIONES_TECNO CURSOR FOR


/*----------------------------------------------------------------------*/
/*-				CONSULTAS LAS GESTIONES DEL DIA ACTUAL			       -*/
/*----------------------------------------------------------------------*/
							SELECT              GES.FLD_COD_USU,  -- COD DE USUARIO
												GES.fld_res_cli,  -- SUBREPUESTA
												GES.fld_comenta,  -- COMENTARIO
												GES.IDLLAMADA,    -- INTERACCION DISCADOR
												GES.fld_fec_ing,  -- FECHA ACCION
												GES.fld_rut_cli   -- IDENTIFICADOR 
						   FROM			     	tecnocob..tbl_historial                      GES WITH(NOLOCK)
	   					   WHERE                GES.fld_cod_emp     			     =		 'TNR'
						   AND					GES.FLD_COD_USU	             	    !=		 'discador'
					  	   AND					GES.idllamada                       !=       ''
						   AND					CAST(GES.fld_fec_ing AS DATE)        =        CAST(GETDATE() AS DATE)  

			 OPEN RECORRE_GESTIONES_TECNO
			 FETCH NEXT FROM RECORRE_GESTIONES_TECNO
				    INTO @COD_USUARIO,@RES_CLI,@COMENTARIO,@INTERACCION_DISCADOR,@FECHA_GESTION,@IDENTIFICADOR
			 WHILE @@FETCH_STATUS = 0  
			 BEGIN

/*----------------------------------------------------------------------*/
/*-						HOMOLOGACION DE DATOS					       -*/
/*----------------------------------------------------------------------*/
							SET @NRO_REGISTRO    =   @NRO_REGISTRO + 1

							SET @ID_USUARIO	  =  (SELECT ID_USUARIO 
													FROM IBR_ALO_V2..USUARIO WITH(NOLOCK) 
													WHERE LOGIN = @COD_USUARIO)

							SET @ID_SUBRESPUESTA =  (SELECT TOP 1 ID_RESPUESTA 
													FROM   IBR_ALO_V2..HOMOLOGACION_GESTION WITH(NOLOCK)
													WHERE  FLD_RES_CLI = @RES_CLI
													AND    CEDENTE = 'TNR')
			
							SET @ID_CLIENTE      = (SELECT  ID_CLIENTE FROM IBR_ALO_V2..CLIENTE WITH(NOLOCK) 
								                    WHERE   IDENTIFICADOR = IBR_ALO_V2.dbo.FN_QUITAR_CEROS_IZQ(@IDENTIFICADOR)
													AND     ID_CEDENTE = 19)

/*----------------------------------------------------------------------*/
/*-							INSERTA DATOS EN LA TABLA GESTIONES	       -*/
/*----------------------------------------------------------------------*/
							INSERT INTO IBR_ALO_V2..GESTION
							(ID_CLIENTE       ,ID_USUARIO             ,  ID_SUB_RESPUESTA      , ID_TIPO_ACCION  
							,FECHA_GESTION    ,COMENTARIO             ,  INTERACCION_DISCADOR  , NRO_DEPENDIENTE)
							VALUES
							(@ID_CLIENTE      , @ID_USUARIO           , @ID_SUBRESPUESTA      , 1 
							,@FECHA_GESTION   ,@COMENTARIO            , @INTERACCION_DISCADOR , 0)
		


			 FETCH NEXT FROM RECORRE_GESTIONES_TECNO
							 INTO @COD_USUARIO,@RES_CLI,@COMENTARIO,@INTERACCION_DISCADOR,@FECHA_GESTION,@IDENTIFICADOR
			 END
			 CLOSE RECORRE_GESTIONES_TECNO
			 DEALLOCATE RECORRE_GESTIONES_TECNO			 
/*----------------------------------------------------------------------*/
/*-						CIERRE DEL CURSOR				 			   -*/
/*----------------------------------------------------------------------*/

