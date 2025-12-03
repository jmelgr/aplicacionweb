import React, { useState } from 'react';
import './index.css';

function App() {
  const [file, setFile] = useState(null);
  const [message, setMessage] = useState('');
  const [downloadUrl, setDownloadUrl] = useState('');

  const handleFileChange = (e) => {
    setFile(e.target.files[0]);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    if (e.dataTransfer.files.length) {
      setFile(e.dataTransfer.files[0]);
    }
  };

  const handleUpload = async () => {
    if (!file) return setMessage('Selecciona un archivo primero');
    setMessage('Subiendo...');

    const formData = new FormData();
    formData.append('file', file);

    try {
      const res = await fetch(`${import.meta.env.VITE_API_URL}/upload`, {
        method: 'POST',
        body: formData,
      });
      const data = await res.json();
      setMessage('Archivo subido correctamente');
      setDownloadUrl(`${import.meta.env.VITE_API_URL}/download/${data.uuid}`);
    } catch (err) {
      console.error(err);
      setMessage('Error al subir archivo');
    }
  };

  return (
    <div
      className="h-screen w-screen flex items-center justify-center 
                 bg-gradient-to-br from-purple-900 via-purple-800 to-purple-900 
                 text-purple-300 font-mono"
      onDrop={handleDrop}
      onDragOver={(e) => e.preventDefault()}
    >
      <div className="w-full h-full flex flex-col items-center justify-center 
                      border-4 border-dashed border-purple-500 rounded-lg 
                      transition-all duration-300 hover:bg-black/40">
        <h1 className="text-4xl md:text-6xl font-bold mb-6 tracking-widest 
                       text-purple-400 drop-shadow-lg">
          404 FILES
        </h1>

        <p className="mb-6 text-lg text-purple-300/80">
          Sube tu archivo de manera segura
        </p>

        <input
          type="file"
          onChange={handleFileChange}
          className="mb-6 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0
                     file:text-sm file:font-semibold file:bg-purple-600 file:text-white
                     hover:file:bg-purple-500 cursor-pointer"
        />

        <button
          onClick={handleUpload}
          className="px-8 py-3 bg-purple-600 text-white font-bold rounded-md 
                     hover:bg-purple-500 transition-all duration-200"
        >
          SUBIR ARCHIVO
        </button>

        {message && (
          <p className="mt-6 text-purple-300 text-lg animate-pulse">{message}</p>
        )}
        {downloadUrl && (
          <div className="mt-4 p-4 bg-black/50 rounded-md">
            <p className="text-purple-400">Enlace generado:</p>
            <a
              href={downloadUrl}
              className="text-purple-300 underline break-all hover:text-purple-200"
            >
              {downloadUrl}
            </a>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;
