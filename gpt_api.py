from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from llama_cpp import Llama
import os

# ====== Setup model ======

# Path to your GGUF model file
MODEL_PATH = "./models/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"

# Initialize the TinyLLaMA model
llm = Llama(
    model_path=MODEL_PATH,
    n_ctx=512,           # Number of context tokens
    n_threads=8,         # Adjust based on your CPU
    n_gpu_layers=0       # If you want to use CPU only
)

# ====== Setup FastAPI app ======

app = FastAPI()

class ChatRequest(BaseModel):
    prompt: str

@app.exception_handler(422)
async def validation_exception_handler(request: Request, exc):
    return JSONResponse(
        status_code=422,
        content={"error": "Validation error", "details": exc.errors()},
    )

@app.get("/")
def read_root():
    return {"message": "TinyLLaMA API is running!"}

@app.post("/chat")
async def chat(request: ChatRequest):
    try:
        output = llm(
            prompt=request.prompt,
            max_tokens=200,
            stop=["</s>"],
            echo=False
        )
        reply = output["choices"][0]["text"].strip()
        return {"response": reply}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"TinyLLaMA error: {str(e)}")
