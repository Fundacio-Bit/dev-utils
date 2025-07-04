package org.fundaciobit.elytronkeycloakbridge;

import io.undertow.servlet.api.DeploymentInfo;
import io.undertow.servlet.api.LoginConfig;
import io.undertow.servlet.api.AuthMethodConfig;
import io.undertow.servlet.ServletExtension;

import javax.servlet.ServletContext;

import java.util.List;

public class KeycloakAuthServletExtension implements ServletExtension {

    @Override
    public void handleDeployment(DeploymentInfo deploymentInfo, ServletContext servletContext) {
        LoginConfig loginConfig = deploymentInfo.getLoginConfig();
        if (loginConfig != null) {
            List<AuthMethodConfig> authMethodConfigs = loginConfig.getAuthMethods();
            if (authMethodConfigs != null) {
                for (AuthMethodConfig methodConfig : authMethodConfigs) {
                    if ("KEYCLOAK".equalsIgnoreCase(methodConfig.getName())) {
                        // Reemplazamos el login config con el nuevo método OIDC
                        deploymentInfo.setLoginConfig(
                            new LoginConfig("OIDC", loginConfig.getRealmName(), loginConfig.getLoginPage(), loginConfig.getErrorPage())
                        );
                        break;
                    }
                }
            }
        }
    }
}
