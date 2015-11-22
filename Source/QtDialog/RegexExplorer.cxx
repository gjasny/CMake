/*============================================================================
  CMake - Cross Platform Makefile Generator
  Copyright 2015 Kitware, Inc., Gregor Jasny

  Distributed under the OSI-approved BSD License (the "License");
  see accompanying file Copyright.txt for details.

  This software is distributed WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the License for more information.
============================================================================*/

#include "RegexExplorer.h"

RegexExplorer::RegexExplorer(QWidget* p) : m_matched(false)
{
  this->setupUi(this);

  for (int i = 1; i < cmsys::RegularExpression::NSUBEXP; ++i) {
    matchNumber->addItem(
      QString("Match %1").arg(QString::number(i)),
      QVariant(i));
  }
  matchNumber->setCurrentIndex(0);
}

void RegexExplorer::setStatusColor(QWidget* widget, bool successful)
{
  QColor color = successful ? QColor(0, 127, 0) : Qt::red;

  QPalette palette = widget->palette();
  palette.setColor(QPalette::Foreground, color);
  widget->setPalette(palette);
}

void RegexExplorer::on_inputText_textChanged()
{
  if (!m_regexParser.is_valid()) return;

  QString plainText = inputText->toPlainText();
  m_text = plainText.toStdString();

  m_matched = m_regexParser.find(m_text);

  setStatusColor(labelRegexMatch, m_matched);

  if (!m_matched) {
    match0->setPlainText(QString());
    matchN->setPlainText(QString());
    return;
  }

  match0->setPlainText(QString::fromStdString(m_regexParser.match(0)));

  on_matchNumber_currentIndexChanged(matchNumber->currentIndex());
}

void RegexExplorer::on_regularExpression_textChanged(const QString& text)
{
  m_regex = text.toStdString();
  bool validExpression = m_regexParser.compile(m_regex);

  setStatusColor(labelRegexValid, validExpression);

  if (validExpression) {
    on_inputText_textChanged();
  }
}

void RegexExplorer::on_matchNumber_currentIndexChanged(int index)
{
  if (!m_matched) return;

  QVariant data = matchNumber->itemData(index);
  int idx = data.toInt();

  if (idx < 1 || idx >= cmsys::RegularExpression::NSUBEXP) return;

  matchN->setPlainText(QString::fromStdString(m_regexParser.match(idx)));
}
