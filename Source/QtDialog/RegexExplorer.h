/*============================================================================
  CMake - Cross Platform Makefile Generator
  Copyright 2015 Kitware, Inc., Gregor Jasny

  Distributed under the OSI-approved BSD License (the "License");
  see accompanying file Copyright.txt for details.

  This software is distributed WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the License for more information.
============================================================================*/

#ifndef RegexExplorer_h
#define RegexExplorer_h

#include <cmsys/RegularExpression.hxx>

#include <QDialog>
#include <QWidget>
#include <QCheckBox>
#include <QStringList>

#include "QCMake.h"
#include "ui_RegexExplorer.h"

class RegexExplorer : public QDialog, public Ui::RegexExplorer
{
  Q_OBJECT
public:
  RegexExplorer(QWidget* p);

private slots:
  void on_inputText_textChanged();
  void on_regularExpression_textChanged(const QString& text);
  void on_matchNumber_currentIndexChanged(int index);

  static void setBackgroundColor(QWidget* widget, const QColor& color);

private:
  cmsys::RegularExpression m_regexParser;
  std::string m_text;
  std::string m_regex;
  bool m_matched;
};

#endif
