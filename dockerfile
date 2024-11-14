FROM alpine

ARG Target=/home
ENV Target=${Target}

ARG State=/integ
ENV State=${State}

ARG enableDeletedLog=true
ENV enableDeletedLog=${enableDeletedLog}

ARG enableCreatedLog=false
ENV enableCreatedLog=${enableCreatedLog}

RUN apk update && apk upgrade
RUN apk add powershell
RUN mkdir -p /integ /src
ADD ./src /src
WORKDIR /src
CMD [ "sh","run.sh" ]