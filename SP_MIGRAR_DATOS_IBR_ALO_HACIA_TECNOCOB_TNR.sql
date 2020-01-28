	
	
	
	USE tecnocob
	GO

	/*

/*----------------------------------------------------------------------*/
/*-						DECLARACION DE VARIABLES					   -*/
/*----------------------------------------------------------------------*/
	DECLARE          @ID_CEDENTE        INT = 19
					,@EMPRESA			VARCHAR(4) = 'TNR'	
					,@IDENTIFICADOR     VARCHAR(255)
					,@LOGIN				VARCHAR(255)
					,@FECHA_GESTION		DATETIME
					,@ID_SUB_RESPUESTA	INT
					,@COMENTARIO		VARCHAR(255)	
					,@INTERACCION_DISCADOR	VARCHAR(255)

/*----------------------------------------------------------------------*/
/*-				CURSOR PARA TRASPASO DE GESTIONES DIARIAS			   -*/
/*----------------------------------------------------------------------*/
			 DECLARE RECORRE_GESTIONES_ALO CURSOR FOR

/*----------------------------------------------------------------------*/
/*-				CONSULTAS LAS GESTIONES DEL DIA ACTUAL			       -*/
/*----------------------------------------------------------------------*/
							 SELECT           CLI.IDENTIFICADOR  
											 ,USU.LOGIN
											 ,GES.FECHA_GESTION
											 ,GES.ID_SUB_RESPUESTA
											 ,GES.COMENTARIO
											 ,GES.INTERACCION_DISCADOR
							 FROM             IBR_ALO_V2..GESTION     GES WITH(NOLOCK)
							 INNER JOIN       IBR_ALO_V2..CLIENTE     CLI WITH(NOLOCK)
							 ON				  GES.ID_CLIENTE       =  CLI.ID_CLIENTE
							 INNER JOIN		  IBR_ALO_V2..USUARIO	  USU WITH(NOLOCK)
							 ON			      USU.ID_USUARIO       =  GES.ID_USUARIO
							 WHERE			  CLI.ID_CEDENTE	   =  @ID_CEDENTE
							 AND			  CAST(GES.FECHA_GESTION AS date) = CAST(GETDATE() AS date)

			 OPEN RECORRE_GESTIONES_ALO
			 FETCH NEXT FROM RECORRE_GESTIONES_ALO
				    INTO @IDENTIFICADOR,@LOGIN,@FECHA_GESTION,@ID_SUB_RESPUESTA,@COMENTARIO,@INTERACCION_DISCADOR	
			 WHILE @@FETCH_STATUS = 0  
			 BEGIN


/*----------------------------------------------------------------------*/
/*-				HOMOLOGACION DE DATOS							       -*/
/*----------------------------------------------------------------------*/
						SET   @IDENTIFICADOR = right('00000000000'+ltrim(rtrim(@IDENTIFICADOR)),11)

						SET   @ID_SUB_RESPUESTA =( SELECT TOP 1 FLD_RES_CLI
												   FROM IBR_ALO_V2..HOMOLOGACION_GESTION WITH(NOLOCK)
												   WHERE ID_RESPUESTA = @ID_SUB_RESPUESTA
												   AND CEDENTE = @EMPRESA)


/*----------------------------------------------------------------------*/
/*-				INSERTA REGISTRO EN LA TBL_HISTORIAL			       -*/
/*----------------------------------------------------------------------*/

							IF NOT EXISTS(SELECT 1 
										  FROM   tecnocob..tbl_historial 
										  WHERE  fld_cod_emp = @EMPRESA
										  AND    idllamada   = @INTERACCION_DISCADOR)
							BEGIN 
 									INSERT INTO tecnocob..tbl_historial
												(fld_rut_cli           ,fld_cod_due           ,fld_pri_acc           ,fld_pri_rut
												,fld_acc_sis           ,fld_fec_acc           ,fld_res_cli           ,fld_fec_res
												,fld_fec_vis           ,fld_fec_ipr           ,fld_his_tel           ,fld_cor_dir
												,fld_cod_usu           ,fld_tip_usu           ,fld_num_pag           ,fld_can_cuo
												,fld_mto_cob           ,flx_comenta           ,fld_fec_ing           ,fld_cod_emp
												,fld_fec_ges           ,fld_comenta           ,fld_campana           ,fld_rut_ava
												,fld_motivo_no_pago           ,idllamada)
											VALUES
												(@IDENTIFICADOR		  ,@LOGIN                ,0                     ,0  
												,135                   ,@FECHA_GESTION        ,@ID_SUB_RESPUESTA     ,@FECHA_GESTION
												,@FECHA_GESTION        ,@FECHA_GESTION        ,0                     ,0
												,@LOGIN                ,5                     ,0                     ,0
												,0                     ,'ADM'                 ,@FECHA_GESTION        ,@EMPRESA
												,@FECHA_GESTION        ,@COMENTARIO           ,''                    ,''   
												,0        ,@INTERACCION_DISCADOR)
												
							END 


			 FETCH NEXT FROM RECORRE_GESTIONES_ALO
										    INTO @IDENTIFICADOR,@LOGIN,@FECHA_GESTION,@ID_SUB_RESPUESTA,@COMENTARIO,@INTERACCION_DISCADOR
			 END
			 CLOSE RECORRE_GESTIONES_ALO
			 DEALLOCATE RECORRE_GESTIONES_ALO			 
/*----------------------------------------------------------------------*/
/*-						CIERRE DEL CURSOR				 			   -*/
/*----------------------------------------------------------------------*/

*/