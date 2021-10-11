cria_novo_layout
	curl -X POST "http://192.9.100.171:8081/api/layouts" -H "accept: application/json" -H "Authorization: bearer eyJ1c2VyTmFtZSI6ImFkbWluIn0.Y2uaNRFhpf0PlifqYIwiXa42rJ6mSDyDtDdGykem7fA" -H "Content-Type: application/json" -d "{ \"name\": \"Teste\"}"

adiciona_camera_em_layout
	curl -X POST "http://192.9.100.171:8081/api/layouts/%7B49FBE2A4-6F7A-4B99-BA3B-02EFDECFE0C4%7D/cameras" -H "accept: application/json" -H "Authorization: bearer eyJ1c2VyTmFtZSI6ImFkbWluIn0.Y2uaNRFhpf0PlifqYIwiXa42rJ6mSDyDtDdGykem7fA" -H "Content-Type: application/json" -d "{ \"aspectRatio\": 0, \"zoom\": 1, \"centerX\": 0, \"centerY\": 0, \"sequence\": 5, \"serverGuid\": \"{E336B0B7-ACF5-46A8-A2F5-BB6DB05339D2}\", \"cameraId\": 0, \"allowDuplicates\": true}"

