USE tecnocob
GO
 
  DECLARE                                    @ID_CEDENTE                       INT                            
                                            ,@ID_ESTADO_CLIENTE                INT          
                                            ,@IDENTIFICADOR                    VARCHAR(50)       
                                            ,@NOMBRE                           VARCHAR(100)       
                                            ,@TRAMO                            VARCHAR(100)       
                                            ,@FECHA_CARGA                      DATETIME      
                                            ,@FECHA_REFRESCO                   DATETIME       
                                            ,@ESTADO                           BIT       
                                            ,@ORIGEN                           VARCHAR(2)         
                                            ,@NRO_CARGA                        INT       
                                            ,@REGISTRO                         INT    = 0   
                                            ,@FILE_ID_CLIENTE                  INT
											,@ID_CLIENTE                       INT   -- VARIABLE RETORNA EL SP
	
   DECLARE RECORRE_CLIENTE_TNR CURSOR FOR

   			   SELECT      19                                      -- ID_CEDENTE 
						  ,1                                       -- ID_ESTADO_CLIENTE
						  ,dbo.Fun_fonos_QuitarCeros2(fld_rut_cli) -- IDENTIFICADOR
						  ,fld_nom_cli                             -- NOMBRE
						  ,''									   -- TRAMO  
   						  ,GETDATE()							   -- FECHA_CARGA
						  ,GETDATE()							   -- FECHA_REFRESCO
						  ,1									   -- ESTADO
						  ,'CA'									   -- ORIGEN
					      ,'2219'								   -- NUMERO DE CARGA ID_EMPRESA + ID CENDENTE 
			   FROM        tbl_clientes  WITH(NOLOCK)
			   WHERE       fld_cod_emp = 'TNR'

   OPEN RECORRE_CLIENTE_TNR
   FETCH NEXT FROM RECORRE_CLIENTE_TNR
   INTO                                      @ID_CEDENTE                                                   
                                            ,@ID_ESTADO_CLIENTE                          
                                            ,@IDENTIFICADOR                        
                                            ,@NOMBRE                                  
                                            ,@TRAMO                                   
                                            ,@FECHA_CARGA                            
                                            ,@FECHA_REFRESCO                          
                                            ,@ESTADO                                  
                                            ,@ORIGEN                                 
                                            ,@NRO_CARGA                               

   WHILE @@FETCH_STATUS = 0  
      BEGIN

	    BEGIN TRY

				   SET @REGISTRO      = @REGISTRO + 1
				   SET @IDENTIFICADOR = DBO.FN_VALIDAR_RUT_CL(@IDENTIFICADOR) 

				   IF @IDENTIFICADOR != '0'
				   BEGIN

				   /********************************/
				   /**     CRESATE CLIENTE        **/
				   /********************************/
								 EXEC @ID_CLIENTE = IBR_ALO_V2..SP_CREATE_CLIENTE  
									                                             @ID_CEDENTE                                                   
																				  ,@ID_ESTADO_CLIENTE                          
																				  ,@IDENTIFICADOR                        
																				  ,@IDENTIFICADOR                        
																				  ,@NOMBRE                                  
																				  ,@TRAMO                                   
																				  ,@FECHA_CARGA                            
																				  ,@FECHA_REFRESCO                          
																				  ,@ESTADO                                  
																				  ,@ORIGEN                                 
																				  ,@NRO_CARGA                               
																				  ,@REGISTRO                          
									 											  ,0  
						
				   /********************************/
				   /**     CREATE CLIENTE         **/
				   /********************************/				
								 EXEC IBR_ALO_V2..SP_CREATE_CONTRATO 	@ID_CLIENTE
																	    ,22   -- ID_EMPRESA 
																		,@NRO_CARGA
																		,@REGISTRO
																		,0
					 
					END
		END TRY
		BEGIN CATCH



		END CATCH



		PRINT 'PASANDO POR EL REGISTRO: ' + CAST(@REGISTRO AS VARCHAR) + '-' + @IDENTIFICADOR

        FETCH NEXT FROM RECORRE_CLIENTE_TNR
        INTO                                @ID_CEDENTE                                                   
                                            ,@ID_ESTADO_CLIENTE                          
                                            ,@IDENTIFICADOR                        
                                            ,@NOMBRE                                  
                                            ,@TRAMO                                   
                                            ,@FECHA_CARGA                            
                                            ,@FECHA_REFRESCO                          
                                            ,@ESTADO                                  
                                            ,@ORIGEN                                 
                                            ,@NRO_CARGA                               


END
CLOSE RECORRE_CLIENTE_TNR
DEALLOCATE RECORRE_CLIENTE_TNR



