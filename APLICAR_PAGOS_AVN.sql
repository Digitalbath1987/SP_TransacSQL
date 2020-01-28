
/***************************************************/
/***          CONSULTAR TABLAS CREADAS           **/
/***************************************************/
SELECT
 INTERFAZ_CODIGO_INTERFAZ
,INTERFAZ_ARCHIVO_ARCHIVO
,INTERFAZ_CARPETA_RUTA_CREADA 
,INTERFAZ_ARCHIVO_TABLA
,ID_INTERFAZ_EJECUCION
,INTERFAZ_ARCHIVO_FECHA_CARGA 
FROM ibr_reporte.dbo.view_interfaz_carga 
WHERE EMPRESA_CODIGO_EMPRESA='avn' 
AND ID_INTERFAZ IN (17,18)
ORDER BY 5 DESC

/***************************************************/
/***          CONSULTAR DATOS DE LA TABLA        **/
/***************************************************/
select * from fobos_69.ibr_file.dbo.FILE_CL_AVN_2019_10_29_18_1223






/***************************************************/
/*** PAGO CASTIGO (17,NUMERO INTERFAS EJEC)      **/
/***************************************************/
EXEC IBR_ALO_HISTO.DBO.SP_CREATE_APLICA_PAGO_AVN 17,1277




/***************************************************/
/***     PAGO COBRANZA  (18,NUMERO INTERFAS EJEC) **/
/***************************************************/
EXEC IBR_ALO_HISTO.DBO.SP_CREATE_APLICA_PAGO_AVN 18,1432






/*Total de pagos*/
  select * 
  from IBR_ALO.DBO.PAGOS_CARGA (nolock) 
  where EMPRESA = 'AVN' 
  and fecha_Carga >='20190730'
   AND NRO_CARGA in (783)
  order by nro_registro
 
/*Pagos Aplicados*/
 select * 
 from IBR_ALO.DBO.pagos_cedente (nolock) 
 where NRO_CARGA in (783)
  and len(producto)>1 
  order by FECHA_CALCULO desc