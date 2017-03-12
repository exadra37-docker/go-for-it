# @package exadra37-docker-images/dockerize-graphical-user-interface-app-demo
# @link    https://gitlab.com/u/exadra37-docker-images/dockerize-graphical-user-interface-app-demo
# @since   12 March 2017
# @license GPL-3.0
# @author  Exadra37(Paulo Silva) <exadra37ingmailpointcom>
#
# Social Links:
# @link    Auhthor:  https://exadra37.com
# @link    Github:   https://gitlab.com/Exadra37
# @link    Github:   https://github.com/Exadra37
# @link    Linkedin: https://uk.linkedin.com/in/exadra37
# @link    Twitter:  https://twitter.com/Exadra37

FROM exadra37/dockerize-graphical-user-interface-app

LABEL "com.exadra37.vendor"="Exadra37"
LABEL com.exadra37.package-name="exadra37-docker-images/dockerize-graphical-user-interface-app-demo"
LABEL version="0.0.1.0"
LABEL description="Demo to Dockerize any App with a graphical user interface."

RUN apt-get update && \
    apt-get -y upgrade && \

    # Add PPA for Go For It
    apt-get -y install \
        software-properties-common \
        python-software-properties && \
    add-apt-repository -y ppa:mank319/go-for-it && \
    apt-get update && \

    # Install Go For It
    apt-get -y install \
        libcanberra-gtk3-module \
        go-for-it

CMD ["go-for-it"]