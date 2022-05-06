package com.tiobe.julia;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.TerminalNode;

import java.nio.file.Path;

public class Violation {
    private final Rule rule;
    private final int lineNumber;
    private final int columnNumber;
    private final String extraMessage;
    private final String filename;

    Violation(final Rule rule, final Path filename, final ParserRuleContext ctx) {
        this(rule, filename, ctx, "");
    }

    Violation(final Rule rule, final Path filename, final ParserRuleContext ctx, final String extraMessage) {
        this(rule, filename, ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine(), extraMessage);
    }

    Violation(final Rule rule, final Path filename, final TerminalNode node, final String extraMessage) {
        this(rule, filename, node.getSymbol().getLine(), node.getSymbol().getCharPositionInLine(), extraMessage);
    }

    Violation(final Rule rule, final Path filename, final int lineNumber, final int columnNumber) {
        this(rule, filename, lineNumber, columnNumber, "");
    }

    Violation(final Rule rule, final Path filename, final int lineNumber, final int columnNumber, final String extraMessage) {
        this.rule = rule;
        this.lineNumber = lineNumber;
        this.columnNumber = columnNumber;
        this.extraMessage = extraMessage;
        this.filename = filename.toString();
    }

    public void printToStdout() {
        System.out.println();
        System.out.println(filename + "(" + lineNumber + ":" + columnNumber + "):");
        System.out.println("  Synopsis: " + rule.getSynopsis());
        System.out.println("  Rule ID: " + rule.getRuleId());
        if (!extraMessage.isEmpty()) {
            System.out.println("  " + extraMessage);
        }
    }

    public int getLineNumber() {
        return this.lineNumber;
    }

    public String getFilename() {
        return this.filename;
    }
}
