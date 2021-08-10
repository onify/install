FROM mcr.microsoft.com/powershell:lts-nanoserver-1809

COPY ./config.json ./
COPY ./agent.exe ./
COPY ./scripts ./scripts
CMD ["agent.exe", "--agent", "--container"]
