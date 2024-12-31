package com.example.aduser;

import org.springframework.ldap.core.LdapTemplate;
import org.springframework.ldap.query.LdapQuery;
import org.springframework.ldap.query.LdapQueryBuilder;
import org.springframework.ldap.support.LdapNameBuilder;
import org.springframework.stereotype.Service;

import javax.naming.Name;
import javax.naming.directory.Attributes;
import javax.naming.directory.BasicAttribute;
import javax.naming.directory.BasicAttributes;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

@Service
public class ADUser {
    private String city;
    private String fullName;
    private String company;
    private String country;
    private String department;
    private String description;
    private String emailAddress;
    private String employeeID;
    private String officePhone;
    private String samAccountName;
    private String lastName;
    private String title;
    private String objectGuid;
    private String firstname;
    private String homeDirectory;
    private String manager;
    private List<String> memberOf;
    private boolean enabled;
    private Logger logger;
    private LdapTemplate ldapTemplate;

    public ADUser(String samAccountName, String logPath, Logger logger, LdapTemplate ldapTemplate) {
        if (samAccountName == null || samAccountName.isEmpty()) {
            throw new IllegalArgumentException("SamAccountName cannot be null or empty");
        }

        this.logger = logger != null ? logger : new Logger(logPath, Logger.LogLevel.INFO);
        this.ldapTemplate = ldapTemplate;
        this.logger.info("Initializing ADUser for " + samAccountName);
        getAdUser(samAccountName);
    }

    private void getAdUser(String samAccountName) {
        try {
            this.logger.info("Retrieving AD user information for " + samAccountName);
            LdapQuery query = LdapQueryBuilder.query().where("sAMAccountName").is(samAccountName);
            ADUser user = ldapTemplate.findOne(query, ADUser.class);
            if (user != null) {
                mapUserProperties(user);
                this.logger.info("Successfully retrieved AD user information for " + samAccountName);
            } else {
                throw new Exception("No ADUser matches the SAMAccountName: " + samAccountName);
            }
        } catch (Exception ex) {
            String errorMessage = "No ADUser matches the SAMAccountName: " + samAccountName + ". Error: " + ex.getMessage();
            this.logger.error(errorMessage);
            throw new RuntimeException(errorMessage);
        }
    }

    private void mapUserProperties(ADUser user) {
        this.city = user.city;
        this.fullName = user.fullName;
        this.company = user.company;
        this.country = user.country;
        this.department = user.department;
        this.description = user.description;
        this.emailAddress = user.emailAddress;
        this.employeeID = user.employeeID;
        this.officePhone = user.officePhone;
        this.samAccountName = user.samAccountName;
        this.lastName = user.lastName;
        this.title = user.title;
        this.objectGuid = user.objectGuid;
        this.firstname = user.firstname;
        this.homeDirectory = user.homeDirectory;
        this.manager = user.manager;
        this.memberOf = user.memberOf;
        this.enabled = user.enabled;
        this.logger.info("Mapped properties for user " + this.samAccountName);
    }

    public boolean isSamAccountNameUnique(String samAccountName) {
        LdapQuery query = LdapQueryBuilder.query().where("sAMAccountName").is(samAccountName);
        ADUser user = ldapTemplate.findOne(query, ADUser.class);
        return user == null;
    }

    public String generateRandomPassword() {
        int length = 12;
        String chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        Random random = new Random();
        StringBuilder password = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            password.append(chars.charAt(random.nextInt(chars.length())));
        }
        return password.toString();
    }

    public void createNewUser(String givenName, String surname, String samAccountName, boolean enabled) {
        if (!isSamAccountNameUnique(samAccountName)) {
            throw new RuntimeException("SamAccountName '" + samAccountName + "' is already in use");
        }

        String password = generateRandomPassword();
        Name dn = LdapNameBuilder.newInstance()
                .add("ou", "Users")
                .add("dc", "yourdomain")
                .add("dc", "com")
                .build();

        Attributes attributes = new BasicAttributes();
        attributes.put(new BasicAttribute("objectClass", "person"));
        attributes.put(new BasicAttribute("cn", givenName + " " + surname));
        attributes.put(new BasicAttribute("sn", surname));
        attributes.put(new BasicAttribute("sAMAccountName", samAccountName));
        attributes.put(new BasicAttribute("userPassword", password));
        attributes.put(new BasicAttribute("userPrincipalName", samAccountName + "@yourdomain.com"));
        attributes.put(new BasicAttribute("givenName", givenName));
        attributes.put(new BasicAttribute("displayName", givenName + " " + surname));
        attributes.put(new BasicAttribute("enabled", String.valueOf(enabled)));

        ldapTemplate.bind(dn, null, attributes);
        this.logger.info("Successfully created AD user " + samAccountName + " with password " + password);
    }

    public void enable(String samAccountName) {
        modifyUserAttribute(samAccountName, "userAccountControl", "512");
        this.logger.info("Successfully enabled AD account for " + samAccountName);
    }

    public void disable(String samAccountName) {
        modifyUserAttribute(samAccountName, "userAccountControl", "514");
        this.logger.info("Successfully disabled AD account for " + samAccountName);
    }

    public void setPassword(String samAccountName, String newPassword) {
        modifyUserAttribute(samAccountName, "userPassword", newPassword);
        this.logger.info("Successfully set password for " + samAccountName);
    }

    public void setDescription(String samAccountName, String description) {
        modifyUserAttribute(samAccountName, "description", description);
        this.logger.info("Successfully set description for " + samAccountName);
    }

    public void setCompany(String samAccountName, String company) {
        modifyUserAttribute(samAccountName, "company", company);
        this.logger.info("Successfully set company for " + samAccountName);
    }

    public void clearExpiration(String samAccountName) {
        modifyUserAttribute(samAccountName, "accountExpires", "0");
        this.logger.info("Successfully cleared account expiration date for " + samAccountName);
    }

    public void addToGroup(String samAccountName, String groupName) {
        Name groupDn = LdapNameBuilder.newInstance()
                .add("cn", groupName)
                .add("ou", "Groups")
                .add("dc", "yourdomain")
                .add("dc", "com")
                .build();

        Name userDn = LdapNameBuilder.newInstance()
                .add("cn", samAccountName)
                .add("ou", "Users")
                .add("dc", "yourdomain")
                .add("dc", "com")
                .build();

        ldapTemplate.modifyAttributes(groupDn, new ModificationItem[]{
                new ModificationItem(DirContext.ADD_ATTRIBUTE, new BasicAttribute("member", userDn.toString()))
        });

        this.logger.info("Successfully added " + samAccountName + " to group " + groupName);
    }

    public List<String> getGroupMemberships(String samAccountName) {
        LdapQuery query = LdapQueryBuilder.query().where("sAMAccountName").is(samAccountName);
        ADUser user = ldapTemplate.findOne(query, ADUser.class);
        if (user != null) {
            List<String> groups = user.memberOf.stream().map(group -> group.split(",")[0].substring(3)).collect(Collectors.toList());
            this.logger.info("Successfully retrieved group memberships for " + samAccountName);
            return groups;
        } else {
            throw new RuntimeException("No ADUser matches the SAMAccountName: " + samAccountName);
        }
    }

    private void modifyUserAttribute(String samAccountName, String attributeName, String attributeValue) {
        LdapQuery query = LdapQueryBuilder.query().where("sAMAccountName").is(samAccountName);
        Name dn = ldapTemplate.findOne(query, Name.class);
        if (dn != null) {
            ldapTemplate.modifyAttributes(dn, new ModificationItem[]{
                    new ModificationItem(DirContext.REPLACE_ATTRIBUTE, new BasicAttribute(attributeName, attributeValue))
            });
        } else {
            throw new RuntimeException("No ADUser matches the SAMAccountName: " + samAccountName);
        }
    }
}