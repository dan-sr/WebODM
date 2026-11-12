# WebODM – Examen Unidad I (CTE 334)

Copia de WebODM que instalé en una máquina virtual con Ubuntu Server para procesar fotos de dron y obtener mapas y modelos 3D.

**Cambios que hice:**
- Puse la IP de mi máquina virtual en el archivo `.env`.
- Agregué `instalar_webodm.sh`, un archivo que instala todo de una vez.
- Cambié la base de datos a la versión 18, porque la anterior ya no funciona con WebODM.

**Cómo usarlo:** en la máquina virtual, ejecutar `sudo bash instalar_webodm.sh MI_USUARIO` y abrir `http://IP-DE-LA-MAQUINA:8000` en el navegador.
