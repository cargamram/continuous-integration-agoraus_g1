FROM maven:3-jdk-7

RUN apt-get update && apt-get install -y --no-install-recommends \
		ssh \
	&& rm -rf /var/lib/apt/lists/*

# expose the ssh port [Necessary for comunicate with jenkins master]
EXPOSE 22

# Change root password to Docker!
RUN echo "jenkins:jenkins" | chpasswd
 
# entrypoint by starting sshd
CMD ["/usr/sbin/sshd", "-D"]
