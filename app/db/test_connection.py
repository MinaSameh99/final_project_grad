from app.db.database import engine

print("STARTING TEST")

try:
    conn = engine.connect()
    print("DATABASE CONNECTED SUCCESSFULLY")
    conn.close()

except Exception as e:
    print("CONNECTION FAILED")
    print(e)