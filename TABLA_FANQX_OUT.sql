USE IBR_VENTAS_EXPRESS
GO


IF OBJECT_ID('TMP_FANQX_OUT', 'U') IS NOT NULL
   BEGIN
      DROP TABLE TMP_FANQX_OUT
   END

/*----------------------------------------------------------*/
/*-- PROCEDIMIENTO PARA CREAR TABLA DETALLE_INTERFAZ  -----*/
/*--------------------------------------------------------*/

CREATE TABLE TMP_FANQX_OUT(	 ID_FANQX_OUT       INT NOT NULL IDENTITY(1,1) 
							,GESTION_ID	        INT           NOT NULL
							,ESTADO	            VARCHAR(500)   NULL
							,CLIENTE_ID	        VARCHAR(500)      NOT NULL
							,NOMBRE	            VARCHAR(500)  NULL
							,RUT	            VARCHAR(500)  NULL
							,EJECUTIVO_ID	    VARCHAR(500)            NOT NULL
							,EJECUTIVO	        VARCHAR(500)  NULL
							,FECHA_VENTA	    VARCHAR(500)  NULL
							,TIPIFICACION	    VARCHAR(500)  NULL
							,CODIGO_AREA	    VARCHAR(500)  NULL
							,NUMERO	            VARCHAR(500)  NULL
							,BBD	            VARCHAR(500)  NULL
							,URL	            VARCHAR(800)  NULL
							,EMPRESA_ID	        VARCHAR(500)            NOT NULL
							,NOMBRE_EMPRESA	    VARCHAR(500)  NULL
							,CAMPANA	        VARCHAR(500)  NULL
							,COMENTARIO	        VARCHAR(800)  NULL
							,ESTADO_GESTION_ID	VARCHAR(500)            NOT NULL
							,FECHA_AUDITORIA	VARCHAR(500)  NULL
							,AUDITOR	        VARCHAR(500)  NULL
							,CAMPO	            VARCHAR(500)  NULL
							,AUDITOR_ID  	    VARCHAR(500)  NULL
							,SCORE       	    VARCHAR(500)  NULL
							,NRO_CARGA          VARCHAR(500)  NULL
							,NOMBRE_ARCHIVO     VARCHAR(800)  NULL
							,FECHA_CARGA        DATETIME 					 
                      )
GO

CREATE INDEX ID_GESTION ON TMP_FANQX_OUT (GESTION_ID,NRO_CARGA)



