USE [IBR_REPORTE]
GO

/****** Object:  StoredProcedure [dbo].[SP_CREATE_CICLO]    Script Date: 11-12-2019 12:14:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[SP_READ_OBJETO_X_ASIGNACION_PIVOT]
                         @ID_ASIGNACION	INT
						,@ID_CAMPAÑA    INT

As
Begin
SET ROWCOUNT 0
SET NOCOUNT ON
SET ANSI_NULLS OFF

/*-----------------------------------------------------------------*/
/*------------------------- Begin User Code -----------------------*/
/*-----------------------------------------------------------------*/
/*-----------------------------------------------------------------*/
/* DATOS DEL SERVICIO                                              */
/*-----------------------------------------------------------------*/
/* SISTEMA             : MANTENEDORES                              */
/* OBJETIVO            : GENERA TABLA SABANA DE LOS OBJETOS        */
/*-----------------------------------------------------------------*/
/* PROGRAMADOR         : MARIO ROSALES FIGUEROA                    */
/*-----------------------------------------------------------------*/

/*-----------------------------------------------------------------*/
/*                    DECLARACION DE VARIABLES                     */
/*-----------------------------------------------------------------*/

		DECLARE  @COLUMNAS_TABLA   NVARCHAR(MAX) = '', 
				 @COLUMNAS_INSERT  NVARCHAR(MAX) = '',
				 @COD_CAMPANA      VARCHAR(255),
				 @CUR_ID_ASIGNACION  INT,
				 @CUR_OBJETO         INT,
				 @CUR_VALOR          VARCHAR(255)
 
/*-----------------------------------------------------------------*/
/*                       OBTENGO CODIGO CAMPANA                    */
/*-----------------------------------------------------------------*/

		SET @COD_CAMPANA = (SELECT CODIGO FROM IBR_VENTAS_EXPRESS.dbo.CAMPANA CAM WITH(NOLOCK) WHERE ID_CAMPANA = 19) --@ID_CAMPAÑA)

/*-----------------------------------------------------------------*/
/*                       OBTENGO LAS COLUMNAS                      */
/*-----------------------------------------------------------------*/

		SELECT        @COLUMNAS_TABLA     +=     QUOTENAME(OBJ.CODIGO) + ' VARCHAR(255),'
		             ,@COLUMNAS_INSERT    +=     QUOTENAME(OBJ.CODIGO) + ','
		FROM          IBR_VENTAS_EXPRESS.DBO.FORMULARIO                 FORM WITH(NOLOCK)
		INNER JOIN    IBR_VENTAS_EXPRESS.DBO.OBJETO                     OBJ  WITH(NOLOCK)
		ON            FORM.ID_OBJETO       =     OBJ.ID_OBJETO 
		AND           FORM.ID_ASIGNACION   =     @ID_ASIGNACION

/*-----------------------------------------------------------------*/
/*                     QUITO LA ULTIMA COMA                        */
/*-----------------------------------------------------------------*/

		SET @COLUMNAS_TABLA  = LEFT(@COLUMNAS_TABLA, LEN(@COLUMNAS_TABLA) - 1)
		SET @COLUMNAS_INSERT = LEFT(@COLUMNAS_INSERT, LEN(@COLUMNAS_INSERT) - 1)

/*-----------------------------------------------------------------*/
/*          SI NO EXISTE CONTRULLE LA TABLA SABANA                 */
/*-----------------------------------------------------------------*/
   
   if NOT EXISTS (SELECT 1 FROM sys.objects WHERE NAME = 'TMP_GESTIONES_'+ @COD_CAMPANA )
   BEGIN
 
		EXEC ('CREATE TABLE TMP_GESTIONES_'+ @COD_CAMPANA  +' (ID INT IDENTITY(1,1),ID_ASIG
		NACION INT,ID_CAMPAÑA INT,'+ @COLUMNAS_TABLA +');
			  CREATE CLUSTERED INDEX INDEX_ASIGNACION ON TMP_GESTIONES_'+ @COD_CAMPANA  +' (ID_ASIGNACION);')
   END

/*-----------------------------------------------------------------*/
/*     VALIDA QUE ID ASIGNACION  NO SE ENCUENTRE EN TABLA SABANA   */
/*-----------------------------------------------------------------*/

	   EXEC ('IF NOT EXISTS (SELECT 1 FROM TMP_GESTIONES_MOV_VE WITH(NOLOCK) WHERE ID_ASIGNACION = @ID_ASIGNACION )
			  BEGIN
				   INSERT INTO TMP_GESTIONES_'+ @COD_CAMPANA  +'(ID_ASIGNACION,ID_CAMPAÑA) VALUES (' + @ID_ASIGNACION + ','+ @ID_CAMPAÑA +')
			  END;')

/*-----------------------------------------------------------------*/
/*--                CURSOR PARA REGISTRAR OBJETO                --*/
/*-----------------------------------------------------------------*/

		DECLARE REGISTRAR_OBJETOS CURSOR FOR
   
	  				SELECT    ID_ASIGNACION
					         ,OBJ.CODIGO  AS OBJETO 
					         ,FORM.VALOR
					  
					FROM                IBR_VENTAS_EXPRESS.dbo.FORMULARIO FORM WITH(NOLOCK)
					INNER JOIN          IBR_VENTAS_EXPRESS.dbo.OBJETO     OBJ  WITH(NOLOCK)
					ON                  FORM.ID_OBJETO      =             OBJ.ID_OBJETO
					WHERE ID_ASIGNACION = 12
	
		OPEN REGISTRAR_OBJETOS
		FETCH NEXT FROM REGISTRAR_OBJETOS
			INTO               @CUR_ID_ASIGNACION                              
							  ,@CUR_OBJETO                  
							  ,@CUR_VALOR                                   
                    
        WHILE @@FETCH_STATUS = 0  
        BEGIN

		       
			   EXEC ('UPDATE TMP_GESTIONES__'+ @COD_CAMPANA  +'
				      SET    '+ @CUR_OBJETO +' = '+ @CUR_VALOR +'
    		          WHERE  ID_ASIGNACION = '+ @CUR_ID_ASIGNACION +'')


		FETCH NEXT FROM REGISTRAR_OBJETOS
			INTO               @CUR_ID_ASIGNACION                              
							  ,@CUR_OBJETO                  
							  ,@CUR_VALOR    

		END
		CLOSE REGISTRAR_OBJETOS
		DEALLOCATE REGISTRAR_OBJETOS

/*-----------------------------------------------------------------*/
/*--                  FIN DEL CURSOR                             --*/
/*-----------------------------------------------------------------*/


/*-----------------------------------------------------------------*/
/*------------------------- End User Code -------------------------*/
/*-----------------------------------------------------------------*/
End

GO


